import pandas as pd

import graphium


def test_list_datasets():
    datasets = graphium.data.utils.list_graphium_datasets()
    assert isinstance(datasets, set)
    assert len(datasets) > 0


def test_download_datasets(tmpdir):
    dataset_dir = tmpdir.mkdir("graphium-datasets")

    data_path = graphium.data.utils.download_graphium_dataset(
        "graphium-zinc-micro", output_path=dataset_dir
    )

    fpath = graphium.utils.fs.join(data_path, "ZINC-micro.csv")
    df = pd.read_csv(fpath)
    assert df.shape == (1000, 4)  # type: ignore
    assert df.columns.tolist() == ["SMILES", "SA", "logp", "score"]  # type: ignore
