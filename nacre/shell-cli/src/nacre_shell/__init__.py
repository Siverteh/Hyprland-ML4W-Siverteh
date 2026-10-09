from nacre_shell.parser import parse_args
from nacre_shell.utils.io import log
from nacre_shell.utils.version import print_version


def main() -> None:
    try:
        parser, args = parse_args()
        if args.version:
            print_version()
        elif "cls" in args:
            args.cls(args).run()
        else:
            parser.print_help()
    except KeyboardInterrupt:
        log("Exiting...")
