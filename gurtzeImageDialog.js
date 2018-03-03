// Generated by CoffeeScript 2.2.2
(function() {
  var CropMarksUI;

  Gurtze.ImageDialog = class ImageDialog extends ContentTools.DialogUI {
    constructor() {
      super('Select image');
      if (Gurtze.IMAGE_GALLERY) {
        console.log('setting up imggallery');
        Gurtze.IMAGE_GALLERY(this);
      }
    }

    mount() {
      super.mount();
      this._img = document.createElement('img');
      this._img.setAttribute('src', 'https://www.placecage.com/gif/200/300');
      // @constructor.createDiv(['gz-thumb'], null, 'quack')
      this._domView.appendChild(this._img);
      return this._addDOMEventListeners();
    }

    setSource(imglist) {
      return console.log('set imglist');
    }

  };

  Gurtze.EXAMPLE_IMAGE_GALLERY = function(dialog) {
    var callback;
    callback = function() {};
    console.log('fetching imglist...');
    return setTimeout(function() {
      console.log('fetched imglist');
      return dialog.setSource([
        {
          src: 'https://www.placecage.com/gif/200/300'
        },
        {
          src: 'https://www.placecage.com/gif/200/300'
        },
        {
          src: 'https://www.placecage.com/gif/200/300'
        }
      ]);
    }, 5 * 1000);
  };

  Gurtze.OldImageDialog = class OldImageDialog extends ContentTools.DialogUI {
    // A dialog to support inserting an image

    // Note: The image dialog doesn't handle the uploading of images it expects
    // this process to be handled by an external library. The external library
    // should be defined as an object against the ContentTools namespace like so:

    // ContentTools.IMAGE_UPLOADER = externalImageUploader

    // The external library should provide an `init(dialog)` method. This method
    // recieves the dialog widget and can then set up all required event bindings
    // to support image uploads.
    constructor() {
      super('Select image');
      // If applied, this is a handle to the crop marks component for the
      // current image.
      this._cropMarks = null;
      // If the dialog is populated, this is the URL of the image
      this._imageURL = null;
      // If the dialog is populated, this is the size of the image
      this._imageSize = null;
      // The upload progress of the dialog (0-100)
      this._progress = 0;
      // The initial state of the dialog
      this._state = 'empty';
      // If an image uploader factory is defined create a new uploader for the
      // dialog.
      if (ContentTools.IMAGE_UPLOADER) {
        ContentTools.IMAGE_UPLOADER(this);
      }
    }

    // Read-only properties
    cropRegion() {
      // Return the defined crop-region (top, left, bottom, right), values are
      // normalized to the range 0.0 - 1.0. If no crop region is defined then
      // the maximum region will be returned (e.g [0, 0, 1, 1])
      if (this._cropMarks) {
        return this._cropMarks.region();
      }
      return [0, 0, 1, 1];
    }

    // Methods
    addCropMarks() {
      // Add crop marks to the current image
      if (this._cropMarks) {
        return;
      }
      // Determine the crop region
      this._cropMarks = new CropMarksUI(this._imageSize);
      this._cropMarks.mount(this._domView);
      // Mark the crop control as active
      return ContentEdit.addCSSClass(this._domCrop, 'ct-control--active');
    }

    clear() {
      // Clear the current image
      if (this._domImage) {
        this._domImage.parentNode.removeChild(this._domImage);
        this._domImage = null;
      }
      // Clear image attributes
      this._imageURL = null;
      this._imageSize = null;
      // Set the dialog to empty
      return this.state('empty');
    }

    mount() {
      var domActions, domProgressBar, domTools;
      // Mount the widget
      super.mount();
      // Update dialog class
      ContentEdit.addCSSClass(this._domElement, 'ct-image-dialog');
      ContentEdit.addCSSClass(this._domElement, 'ct-image-dialog--empty');
      // Update view class
      // ContentEdit.addCSSClass(@_domView, 'ct-image-dialog__view')

      // Add controls

      // Image tools & progress bar
      domTools = this.constructor.createDiv(['ct-control-group', 'ct-control-group--left']);
      this._domControls.appendChild(domTools);
      // Rotate CCW
      this._domRotateCCW = this.constructor.createDiv(['ct-control', 'ct-control--icon', 'ct-control--rotate-ccw']);
      this._domRotateCCW.setAttribute('data-ct-tooltip', ContentEdit._('Rotate') + ' -90°');
      domTools.appendChild(this._domRotateCCW);
      // Rotate CW
      this._domRotateCW = this.constructor.createDiv(['ct-control', 'ct-control--icon', 'ct-control--rotate-cw']);
      this._domRotateCW.setAttribute('data-ct-tooltip', ContentEdit._('Rotate') + ' 90°');
      domTools.appendChild(this._domRotateCW);
      // Rotate CW
      this._domCrop = this.constructor.createDiv(['ct-control', 'ct-control--icon', 'ct-control--crop']);
      this._domCrop.setAttribute('data-ct-tooltip', ContentEdit._('Crop marks'));
      domTools.appendChild(this._domCrop);
      // Progress bar
      domProgressBar = this.constructor.createDiv(['ct-progress-bar']);
      domTools.appendChild(domProgressBar);
      this._domProgress = this.constructor.createDiv(['ct-progress-bar__progress']);
      domProgressBar.appendChild(this._domProgress);
      // Actions
      domActions = this.constructor.createDiv(['ct-control-group', 'ct-control-group--right']);
      this._domControls.appendChild(domActions);
      // Upload button
      this._domUpload = this.constructor.createDiv(['ct-control', 'ct-control--text', 'ct-control--upload']);
      this._domUpload.textContent = ContentEdit._('Upload');
      domActions.appendChild(this._domUpload);
      // File input for upload
      this._domInput = document.createElement('input');
      this._domInput.setAttribute('class', 'ct-image-dialog__file-upload');
      this._domInput.setAttribute('name', 'file');
      this._domInput.setAttribute('type', 'file');
      this._domInput.setAttribute('accept', 'image/*');
      this._domUpload.appendChild(this._domInput);
      // Insert
      this._domInsert = this.constructor.createDiv(['ct-control', 'ct-control--text', 'ct-control--insert']);
      this._domInsert.textContent = ContentEdit._('Insert');
      domActions.appendChild(this._domInsert);
      // Cancel
      this._domCancelUpload = this.constructor.createDiv(['ct-control', 'ct-control--text', 'ct-control--cancel']);
      this._domCancelUpload.textContent = ContentEdit._('Cancel');
      domActions.appendChild(this._domCancelUpload);
      // Clear
      this._domClear = this.constructor.createDiv(['ct-control', 'ct-control--text', 'ct-control--clear']);
      this._domClear.textContent = ContentEdit._('Clear');
      domActions.appendChild(this._domClear);
      // Add interaction handlers
      this._addDOMEventListeners();
      return this.dispatchEvent(this.createEvent('imageuploader.mount'));
    }

    populate(imageURL, imageSize) {
      // Populate the dialog with an image

      // Set image attributes
      this._imageURL = imageURL;
      this._imageSize = imageSize;
      // Check for existing image, if there isn't one add one
      if (!this._domImage) {
        this._domImage = this.constructor.createDiv(['ct-image-dialog__image']);
        this._domView.appendChild(this._domImage);
      }
      // Set the image to appear
      this._domImage.style['background-image'] = `url(${imageURL})`;
      // Set the dialog to populated
      return this.state('populated');
    }

    progress(progress) {
      // Get/Set upload progress
      if (progress === void 0) {
        return this._progress;
      }
      this._progress = progress;
      // Update progress bar width
      if (!this.isMounted()) {
        return;
      }
      return this._domProgress.style.width = `${this._progress}%`;
    }

    removeCropMarks() {
      // Remove crop marks from the current image
      if (!this._cropMarks) {
        return;
      }
      this._cropMarks.unmount();
      this._cropMarks = null;
      // Mark the crop control as no longer active
      return ContentEdit.removeCSSClass(this._domCrop, 'ct-control--active');
    }

    save(imageURL, imageSize, imageAttrs) {
      // Save and insert the current image
      return this.dispatchEvent(this.createEvent('save', {
        'imageURL': imageURL,
        'imageSize': imageSize,
        'imageAttrs': imageAttrs
      }));
    }

    state(state) {
      var prevState;
      // Set/get the state of the dialog (empty, uploading, populated)
      if (state === void 0) {
        return this._state;
      }
      // Check that we need to change the current state of the dialog
      if (this._state === state) {
        return;
      }
      // Modify the state
      prevState = this._state;
      this._state = state;
      // Update state modifier class for the dialog
      if (!this.isMounted()) {
        return;
      }
      ContentEdit.addCSSClass(this._domElement, `ct-image-dialog--${this._state}`);
      return ContentEdit.removeCSSClass(this._domElement, `ct-image-dialog--${prevState}`);
    }

    unmount() {
      // Unmount the component from the DOM
      super.unmount();
      this._domCancelUpload = null;
      this._domClear = null;
      this._domCrop = null;
      this._domInput = null;
      this._domInsert = null;
      this._domProgress = null;
      this._domRotateCCW = null;
      this._domRotateCW = null;
      this._domUpload = null;
      return this.dispatchEvent(this.createEvent('imageuploader.unmount'));
    }

    // Private methods
    _addDOMEventListeners() {
      // Add event listeners for the widget
      super._addDOMEventListeners();
      // File ready for upload
      this._domInput.addEventListener('change', (ev) => {
        var file;
        // Get the file uploaded
        file = ev.target.files[0];
        // Ignore empty file changes (this may occur when we change the
        // value of the input field to '', see issue:
        // https://github.com/GetmeUK/ContentTools/issues/385
        if (!file) {
          return;
        }
        // Clear the file inputs value so that the same file can be uploaded
        // again if the user cancels the upload or clears it and starts then
        // changes their mind.
        ev.target.value = '';
        if (ev.target.value) {
          // Hack for clearing the file field value in IE
          ev.target.type = 'text';
          ev.target.type = 'file';
        }
        return this.dispatchEvent(this.createEvent('imageuploader.fileready', {
          file: file
        }));
      });
      // Cancel upload
      this._domCancelUpload.addEventListener('click', (ev) => {
        return this.dispatchEvent(this.createEvent('imageuploader.cancelupload'));
      });
      // Clear image
      this._domClear.addEventListener('click', (ev) => {
        this.removeCropMarks();
        return this.dispatchEvent(this.createEvent('imageuploader.clear'));
      });
      // Rotate the image
      this._domRotateCCW.addEventListener('click', (ev) => {
        this.removeCropMarks();
        return this.dispatchEvent(this.createEvent('imageuploader.rotateccw'));
      });
      this._domRotateCW.addEventListener('click', (ev) => {
        this.removeCropMarks();
        return this.dispatchEvent(this.createEvent('imageuploader.rotatecw'));
      });
      this._domCrop.addEventListener('click', (ev) => {
        if (this._cropMarks) {
          return this.removeCropMarks();
        } else {
          return this.addCropMarks();
        }
      });
      return this._domInsert.addEventListener('click', (ev) => {
        return this.dispatchEvent(this.createEvent('imageuploader.save'));
      });
    }

  };

  CropMarksUI = class CropMarksUI extends ContentTools.AnchoredComponentUI {
    // Crop marks widget. Allows a crop region to be defined for images in the
    // image dialog.
    constructor(imageSize) {
      super();
      // Set when the component is mounted/fitted, holds the region the
      // crop marks are restricted to.
      this._bounds = null;
      // The handle currently being dragged
      this._dragging = null;
      // The origin of the drag (e.g the top, left coordinates the drag started
      // from).
      this._draggingOrigin = null;
      // The physical size of the image being cropped
      this._imageSize = imageSize;
    }

    // Methods
    mount(domParent, before = null) {
      // Crop marks
      this._domElement = this.constructor.createDiv(['ct-crop-marks']);
      // Clippers
      this._domClipper = this.constructor.createDiv(['ct-crop-marks__clipper']);
      this._domElement.appendChild(this._domClipper);
      // Rulers
      this._domRulers = [this.constructor.createDiv(['ct-crop-marks__ruler', 'ct-crop-marks__ruler--top-left']), this.constructor.createDiv(['ct-crop-marks__ruler', 'ct-crop-marks__ruler--bottom-right'])];
      this._domClipper.appendChild(this._domRulers[0]);
      this._domClipper.appendChild(this._domRulers[1]);
      // Handles
      this._domHandles = [this.constructor.createDiv(['ct-crop-marks__handle', 'ct-crop-marks__handle--top-left']), this.constructor.createDiv(['ct-crop-marks__handle', 'ct-crop-marks__handle--bottom-right'])];
      this._domElement.appendChild(this._domHandles[0]);
      this._domElement.appendChild(this._domHandles[1]);
      // Mount the widget
      super.mount(domParent, before);
      // Fit the component to the parent components image
      return this._fit(domParent);
    }

    region() {
      // Return the crop region (top, left, bottom, right), values are
      // normalized to the range 0.0 - 1.0.
      return [parseFloat(this._domHandles[0].style.top) / this._bounds[1], parseFloat(this._domHandles[0].style.left) / this._bounds[0], parseFloat(this._domHandles[1].style.top) / this._bounds[1], parseFloat(this._domHandles[1].style.left) / this._bounds[0]];
    }

    unmount() {
      // Unmount the component from the DOM
      super.unmount();
      this._domClipper = null;
      this._domHandles = null;
      return this._domRulers = null;
    }

    // Private methods
    _addDOMEventListeners() {
      // Add event listeners for the widget
      super._addDOMEventListeners();
      // Handle the handles being dragged
      this._domHandles[0].addEventListener('mousedown', (ev) => {
        // Check left mouse button used
        if (ev.button === 0) {
          return this._startDrag(0, ev.clientY, ev.clientX);
        }
      });
      return this._domHandles[1].addEventListener('mousedown', (ev) => {
        // Check left mouse button used
        if (ev.button === 0) {
          return this._startDrag(1, ev.clientY, ev.clientX);
        }
      });
    }

    _drag(top, left) {
      var height, minCrop, offsetLeft, offsetTop, width;
      // Handle dragging of handle/ruler
      if (this._dragging === null) {
        return;
      }
      // Prevent content selection while dragging elements
      ContentSelect.Range.unselectAll();
      // Calculate the new position of the handle
      offsetTop = top - this._draggingOrigin[1];
      offsetLeft = left - this._draggingOrigin[0];
      // Apply constraints
      height = this._bounds[1];
      left = 0;
      top = 0;
      width = this._bounds[0];
      // Cannot overlap
      minCrop = Math.min(Math.min(ContentTools.MIN_CROP, height), width);
      if (this._dragging === 0) {
        height = parseInt(this._domHandles[1].style.top) - minCrop;
        width = parseInt(this._domHandles[1].style.left) - minCrop;
      } else {
        left = parseInt(this._domHandles[0].style.left) + minCrop;
        top = parseInt(this._domHandles[0].style.top) + minCrop;
      }
      // Must be within bounds
      offsetTop = Math.min(Math.max(top, offsetTop), height);
      offsetLeft = Math.min(Math.max(left, offsetLeft), width);
      // Move the handle
      this._domHandles[this._dragging].style.top = `${offsetTop}px`;
      this._domHandles[this._dragging].style.left = `${offsetLeft}px`;
      this._domRulers[this._dragging].style.top = `${offsetTop}px`;
      return this._domRulers[this._dragging].style.left = `${offsetLeft}px`;
    }

    _fit(domParent) {
      var height, heightScale, left, ratio, rect, top, width, widthScale;
      // Fit the crop marks element to reflect/overlap the image (displayed in
      // the background of the domParent.

      // Calculate the ratio required to fit the image into the parent DOM
      rect = domParent.getBoundingClientRect();
      widthScale = rect.width / this._imageSize[0];
      heightScale = rect.height / this._imageSize[1];
      ratio = Math.min(widthScale, heightScale);
      // Calculate the position and size for the crop marks element
      width = ratio * this._imageSize[0];
      height = ratio * this._imageSize[1];
      left = (rect.width - width) / 2;
      top = (rect.height - height) / 2;
      // Set the position and size of crop marks element
      this._domElement.style.width = `${width}px`;
      this._domElement.style.height = `${height}px`;
      this._domElement.style.top = `${top}px`;
      this._domElement.style.left = `${left}px`;
      // Position the handles and rulers
      this._domHandles[0].style.top = '0px';
      this._domHandles[0].style.left = '0px';
      this._domHandles[1].style.top = `${height}px`;
      this._domHandles[1].style.left = `${width}px`;
      this._domRulers[0].style.top = '0px';
      this._domRulers[0].style.left = '0px';
      this._domRulers[1].style.top = `${height}px`;
      this._domRulers[1].style.left = `${width}px`;
      // Set the bounds
      return this._bounds = [width, height];
    }

    _startDrag(handleIndex, top, left) {
      var domHandle;
      // Handle start of handle/ruler drag

      // Set dragging state
      domHandle = this._domHandles[handleIndex];
      this._dragging = handleIndex;
      this._draggingOrigin = [left - parseInt(domHandle.style.left), top - parseInt(domHandle.style.top)];
      // Handle any mouse move event (as a drag)
      this._onMouseMove = (ev) => {
        return this._drag(ev.clientY, ev.clientX);
      };
      document.addEventListener('mousemove', this._onMouseMove);
      // Handle any mouse up event (as stop dragging)
      this._onMouseUp = (ev) => {
        return this._stopDrag();
      };
      return document.addEventListener('mouseup', this._onMouseUp);
    }

    _stopDrag() {
      // Handle handle/ruler drag stopping

      // Remove event handlers
      document.removeEventListener('mousemove', this._onMouseMove);
      document.removeEventListener('mouseup', this._onMouseUp);
      // Unset dragging state
      this._dragging = null;
      return this._draggingOrigin = null;
    }

  };

}).call(this);

//# sourceMappingURL=gurtzeImageDialog.js.map
