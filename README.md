# Enlargify

**Enlargify** is a web application that allows users to upload an image, choose from various enlargement algorithms, and view the processed image. The application features a modern, developer-themed UI and supports image enlargement with different interpolation techniques. It also provides options to download the processed image.

## Features

- **Image Upload:** Select and upload images from your local storage.
- **Algorithm Selection:** Choose from multiple enlargement algorithms including Zero Order Hold, Bilinear Interpolation, and Linear Interpolation.
- **Scale Factor:** Adjust the scale factor to control the enlargement size.
- **Image Display:** View the processed image on the same screen.
- **Download Option:** Download the enlarged image to your local machine.
- **Monochromatic Theme:** A sleek, programmer-inspired UI with a modern design.

## Demo

You can view a demonstration of the application here: [Enlargify Demo](https://www.youtube.com/watch?v=2TYwX1Lq_VM)

## Installation

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- Python (for backend)
- [PIP](https://pip.pypa.io/en/stable/installation/) (Python package installer)

### Frontend Setup

1. **Clone the repository:**

    ```sh
    git clone https://github.com/your-repo/enlargify.git
    cd enlargify
    ```

2. **Navigate to the frontend directory:**

    ```sh
    cd lib
    ```

3. **Install Flutter dependencies:**

    ```sh
    flutter pub get
    ```

4. **Run the Flutter application:**

    ```sh
    flutter run
    ```

### Backend Setup

1. **Navigate to the backend directory:**

    ```sh
    cd Backend
    ```

2. **Create a virtual environment (optional but recommended):**

    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```

3. **Install backend dependencies:**

    If you have not created a `requirements.txt` file, install the dependencies manually:

    ```sh
    pip install flask flask-cors pillow numpy
    ```

    If you have a `requirements.txt` file, you can install the dependencies using:

    ```sh
    pip install -r requirements.txt
    ```

4. **Run the Flask server:**

    ```sh
    python main.py
    ```

## Usage

1. **Open the Flutter app** in your web browser.
2. **Select an image** using the "Pick an image" button.
3. **Choose an enlargement algorithm** from the dropdown menu.
4. **Adjust the scale factor** using the slider.
5. **Click "Enlarge Image"** to send the request to the backend.
6. **View the processed image** displayed on the screen.
7. **Download the image** using the "Download Image" button.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you would like to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
