import logging
import sys


class ColoredFormatter(logging.Formatter):
    """Custom formatter that adds color to log levels for terminal output."""

    # ANSI color codes
    COLORS = {
        "ERROR": "\033[91m",  # Red
        "WARNING": "\033[93m",  # Yellow
        "RESET": "\033[0m",  # Reset to default
    }

    def __init__(self, fmt: str | None = None, datefmt: str | None = None) -> None:
        super().__init__(fmt, datefmt)

    def format(self, record: logging.LogRecord) -> str:
        # Get the original formatted message
        original_format = super().format(record)

        # Only add colors if we're outputting to a terminal (not to a file)
        if sys.stderr.isatty():
            level_name = record.levelname
            if level_name in self.COLORS:
                # Color the entire message for ERROR and WARNING
                return f"{self.COLORS[level_name]}{original_format}{self.COLORS['RESET']}"

        return original_format


def configure_logger(name: str = "python_base", level: int = logging.DEBUG) -> logging.Logger:
    """Configure and return logger with specified name and level."""
    logger = logging.getLogger(name)
    logger.setLevel(level)

    ch = logging.StreamHandler()
    ch.setLevel(level)

    formatter = ColoredFormatter("%(asctime)s - %(name)s - %(pathname)s:%(lineno)d - %(levelname)s - %(message)s")

    ch.setFormatter(formatter)
    logger.addHandler(ch)

    return logger


# Module-level logger - can be reconfigured from outside
logger = configure_logger()


def set_logger(new_logger: logging.Logger) -> None:
    """Set the module-level logger to a custom logger instance."""
    global logger
    logger = new_logger
