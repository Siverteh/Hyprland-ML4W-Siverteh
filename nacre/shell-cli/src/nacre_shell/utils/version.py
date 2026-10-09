from importlib.metadata import version, PackageNotFoundError


def print_version():
    try:
        value = version("nacre_shell")
    except PackageNotFoundError:
        value = "source"
    print("Nacre shell CLI " + value)
