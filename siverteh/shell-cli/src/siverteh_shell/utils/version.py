from importlib.metadata import version, PackageNotFoundError


def print_version():
    try:
        value = version("siverteh_shell")
    except PackageNotFoundError:
        value = "source"
    print("Siverteh OS shell CLI " + value)
