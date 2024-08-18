import time


def process_data() -> None:
    """
    This function simulates data processing.
    """
    print("Starting data processing...")
    time.sleep(5)
    print("Data processing completed!")


if __name__ == "__main__":
    while True:
        process_data()
        time.sleep(10)
