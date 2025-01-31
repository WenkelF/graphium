import os
from os.path import dirname, abspath

import unittest as ut

import torch
from copy import deepcopy

from lightning.pytorch.callbacks import Callback

from omegaconf import OmegaConf
import graphium

from graphium.finetuning import modify_cfg_for_finetuning
from graphium.trainer import PredictorModule

from graphium.finetuning import GraphFinetuning

from graphium.config._loader import (
    load_datamodule,
    load_metrics,
    load_architecture,
    load_predictor,
    load_trainer,
    save_params_to_wandb,
    load_accelerator,
)


MAIN_DIR = dirname(dirname(abspath(graphium.__file__)))
CONFIG_FILE = "graphium/config/dummy_finetuning.yaml"

os.chdir(MAIN_DIR)


class Test_Finetuning(ut.TestCase):
    def test_finetuning_pipeline(self):
        # Skip test if PyTDC package not installed
        try:
            import tdc
        except ImportError:
            self.skipTest("PyTDC needs to be installed to run this test. Use `pip install PyTDC`.")

        ##################################################
        ### Test modification of config for finetuning ###
        ##################################################

        cfg = graphium.load_config(name="dummy_finetuning")
        cfg = OmegaConf.to_container(cfg, resolve=True)

        cfg = modify_cfg_for_finetuning(cfg)

        # Initialize the accelerator
        cfg, accelerator_type = load_accelerator(cfg)

        # Load and initialize the dataset
        datamodule = load_datamodule(cfg, accelerator_type)

        # Initialize the network
        model_class, model_kwargs = load_architecture(
            cfg,
            in_dims=datamodule.in_dims,
        )

        datamodule.prepare_data()

        metrics = load_metrics(cfg)

        predictor = load_predictor(
            cfg,
            model_class,
            model_kwargs,
            metrics,
            datamodule.get_task_levels(),
            accelerator_type,
            datamodule.featurization,
            datamodule.task_norms,
        )

        self.assertEqual(
            len(
                predictor.model.pretrained_model.net.task_heads.task_heads["lipophilicity_astrazeneca"].layers
            ),
            3,
        )
        self.assertEqual(
            predictor.model.pretrained_model.net.task_heads.task_heads["lipophilicity_astrazeneca"].out_dim, 8
        )
        self.assertEqual(predictor.model.finetuning_head.net.in_dim, 8)
        self.assertEqual(len(predictor.model.finetuning_head.net.layers), 2)
        self.assertEqual(predictor.model.finetuning_head.net.out_dim, 1)

        ################################################
        ### Test overwriting with pretrained weights ###
        ################################################

        # Load pretrained & replace in predictor
        pretrained_model = PredictorModule.load_pretrained_models(
            cfg["finetuning"]["pretrained_model_name"], device="cpu"
        ).model

        pretrained_model.create_module_map()
        module_map_from_pretrained = deepcopy(pretrained_model._module_map)
        module_map = deepcopy(predictor.model.pretrained_model.net._module_map)

        # Finetuning module has only been partially overwritten
        cfg_finetune = cfg["finetuning"]
        finetuning_module = "".join([cfg_finetune["finetuning_module"], "/", cfg_finetune["task"]])
        finetuning_module_from_pretrained = "".join(
            [cfg_finetune["finetuning_module"], "/", cfg_finetune["sub_module_from_pretrained"]]
        )

        pretrained_layers = module_map[finetuning_module]
        overwritten_layers = module_map_from_pretrained[finetuning_module_from_pretrained]

        for idx, (pretrained, overwritten) in enumerate(zip(pretrained_layers, overwritten_layers)):
            if idx < 1:
                assert torch.equal(pretrained.linear.weight, overwritten.linear.weight)
                assert torch.equal(pretrained.linear.bias, overwritten.linear.bias)
            else:
                assert not torch.equal(pretrained.linear.weight, overwritten.linear.weight)
                assert not torch.equal(pretrained.linear.bias, overwritten.linear.bias)

            if idx + 1 == min(len(pretrained_layers), len(overwritten_layers)):
                break

        _ = module_map.popitem(last=True)
        overwritten_modules = module_map.values()

        _ = module_map_from_pretrained.popitem(last=True)
        pretrained_modules = module_map_from_pretrained.values()

        for overwritten_module, pretrained_module in zip(overwritten_modules, pretrained_modules):
            for overwritten, pretrained in zip(
                overwritten_module.parameters(), pretrained_module.parameters()
            ):
                assert torch.equal(overwritten.data, pretrained.data)

        #################################################
        ### Test correct (un)freezing during training ###
        #################################################

        # Define test callback that checks for correct (un)freezing
        class TestCallback(Callback):
            def __init__(self, cfg):
                super().__init__()

                self.cfg_finetune = cfg["finetuning"]

            def on_train_epoch_start(self, trainer, pl_module):
                module_map = pl_module.model.pretrained_model.net._module_map

                finetuning_module = "".join(
                    [self.cfg_finetune["finetuning_module"], "/", self.cfg_finetune["task"]]
                )
                training_depth = self.cfg_finetune["added_depth"] + self.cfg_finetune.pop(
                    "unfreeze_pretrained_depth", 0
                )

                frozen_parameters, unfrozen_parameters = [], []

                if trainer.current_epoch == 0:
                    frozen = True

                    for module_name, module in module_map.items():
                        if module_name == finetuning_module:
                            # After the finetuning module, all parameters are unfrozen
                            frozen = False

                            frozen_parameters.extend(
                                [
                                    parameter.requires_grad
                                    for parameter in module[:-training_depth].parameters()
                                ]
                            )
                            unfrozen_parameters.extend(
                                [
                                    parameter.requires_grad
                                    for parameter in module[-training_depth:].parameters()
                                ]
                            )
                            continue

                        if frozen:
                            frozen_parameters.extend(
                                [parameter.requires_grad for parameter in module.parameters()]
                            )
                        else:
                            unfrozen_parameters.extend(
                                [parameter.requires_grad for parameter in module.parameters()]
                            )

                    # Finetuning head is always unfrozen
                    unfrozen_parameters.extend(
                        [
                            parameter.requires_grad
                            for parameter in pl_module.model.finetuning_head.parameters()
                        ]
                    )

                    assert not True in frozen_parameters
                    assert not False in unfrozen_parameters

                if trainer.current_epoch == 2:
                    # All parameter are unfrozen starting from epoch_unfreeze_all
                    unfrozen_parameters = [
                        parameter.requires_grad for parameter in pl_module.model.parameters()
                    ]

                    assert not False in unfrozen_parameters

        trainer = load_trainer(cfg, accelerator_type)

        finetuning_training_kwargs = cfg["finetuning"]["training_kwargs"]
        trainer.callbacks.append(GraphFinetuning(**finetuning_training_kwargs))

        # Add test callback to trainer
        trainer.callbacks.append(TestCallback(cfg))

        predictor.set_max_nodes_edges_per_graph(datamodule, stages=["train", "val"])

        # Run the model training
        trainer.fit(model=predictor, datamodule=datamodule)


if __name__ == "__main__":
    ut.main()
