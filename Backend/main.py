from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import io
import os
from PIL import Image
import numpy as np
from datetime import datetime


app = Flask(__name__)
CORS(app)  # Enables CORS for all routes


def zero_order_hold(image_array, scale_factor):
    original_height, original_width = image_array.shape[:2]
    new_height, new_width = int(
        original_height * scale_factor), int(original_width * scale_factor)
    enlarged_image = np.zeros(
        (new_height, new_width, 3), dtype=image_array.dtype)

    for i in range(new_height):
        for j in range(new_width):
            orig_i = int(i // scale_factor)
            orig_j = int(j // scale_factor)
            enlarged_image[i, j] = image_array[orig_i, orig_j]

    return np.repeat(np.repeat(image_array, scale_factor, axis=0), scale_factor, axis=1)


def bilinear_interpolation(image_array, scale_factor):
    original_height, original_width = image_array.shape[:2]
    new_height, new_width = int(
        original_height * scale_factor), int(original_width * scale_factor)
    enlarged_image = np.zeros(
        (new_height, new_width, 3), dtype=image_array.dtype)

    for i in range(new_height):
        for j in range(new_width):
            x = i / scale_factor
            y = j / scale_factor
            x0 = int(x)
            x1 = min(x0 + 1, original_height - 1)
            y0 = int(y)
            y1 = min(y0 + 1, original_width - 1)
            x_weight = x - x0
            y_weight = y - y0

            top_left = image_array[x0, y0]
            top_right = image_array[x0, y1]
            bottom_left = image_array[x1, y0]
            bottom_right = image_array[x1, y1]

            top = top_left * (1 - y_weight) + top_right * y_weight
            bottom = bottom_left * (1 - y_weight) + bottom_right * y_weight
            pixel_value = top * (1 - x_weight) + bottom * x_weight

            enlarged_image[i, j] = pixel_value

    return np.array(Image.fromarray(image_array).resize(
        (int(image_array.shape[1] * scale_factor),
         int(image_array.shape[0] * scale_factor)),
        Image.BILINEAR
    ))


def linear_interpolation(image_array, scale_factor):
    original_height, original_width = image_array.shape[:2]
    new_height, new_width = int(
        original_height * scale_factor), int(original_width * scale_factor)
    enlarged_image = np.zeros(
        (new_height, new_width, 3), dtype=image_array.dtype)

    for i in range(new_height):
        for j in range(new_width):
            x = i / scale_factor
            y = j / scale_factor
            x0 = int(x)
            x1 = min(x0 + 1, original_height - 1)
            y0 = int(y)
            y1 = min(y0 + 1, original_width - 1)
            wx = x - x0
            wy = y - y0

            p1 = (1 - wy) * image_array[x0, y0] + wy * image_array[x0, y1]
            p2 = (1 - wy) * image_array[x1, y0] + wy * image_array[x1, y1]

            enlarged_image[i, j] = (1 - wx) * p1 + wx * p2

    return np.array(Image.fromarray(image_array).resize(
        (int(image_array.shape[1] * scale_factor),
         int(image_array.shape[0] * scale_factor)),
        Image.LINEAR
    ))


@app.route('/enlarge_image', methods=['POST'])
def enlarge_image():
    try:
        # Get image and parameters from request
        image_file = request.files['image']
        algorithm = request.form['algorithm']
        scale_factor = float(request.form['scaleFactor'])

        # Open and process the image
        image = Image.open(image_file)
        image_array = np.array(image)

        if image_array.shape[-1] == 4:  # Check if the image has an alpha channel
            image_array = image_array[:, :, :3]  # Drop the alpha channel

        # Apply the chosen algorithm
        if algorithm == 'zero_order_hold':
            enlarged_image_array = zero_order_hold(image_array, scale_factor)
        elif algorithm == 'bilinear_interpolation':
            enlarged_image_array = bilinear_interpolation(
                image_array, scale_factor)
        elif algorithm == 'linear_interpolation':
            enlarged_image_array = linear_interpolation(
                image_array, scale_factor)
        else:
            return jsonify({'error': 'Invalid algorithm selected'}), 400

        # Convert numpy array back to image
        enlarged_image = Image.fromarray(enlarged_image_array.astype('uint8'))

        # Create a unique filename based on the current timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        output_dir = os.path.join(os.getcwd(), 'results')  # Use absolute path
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
            print(f"Directory created: {output_dir}")

        file_path = os.path.join(output_dir, f'enlarged_image_{timestamp}.png')

        # Save the image to local storage
        enlarged_image.save(file_path)
        print(f"File saved: {file_path}")

        # Return the image file to the client
        return send_file(file_path, mimetype='image/png', as_attachment=True, download_name='enlarged_image.png')

    except Exception as e:
        print(f"Error occurred: {e}")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
