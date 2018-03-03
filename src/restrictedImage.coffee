class ContentTools.RestrictedImageTool extends ContentTools.Tools.Image
    # Register the tool with the toolshelf
    ContentTools.ToolShelf.stow(@, 'restrictedImage')

    # The tooltip and icon modifier CSS class for the tool
    @label = 'Image'
    @icon = 'image'

    @apply: (element, selection, callback) ->
    # Dispatch `apply` event
        toolDetail = {
            'tool': this,
            'element': element,
            'selection': selection
            }
        if not @dispatchEditorEvent('tool-apply', toolDetail)
            return

        # If supported allow store the state for restoring once the dialog is
        # cancelled.
        if element.storeState
            element.storeState()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI()

        # Dialog
        dialog = new ContentTools.RestrictedImageDialog()

        # Support cancelling the dialog
        dialog.addEventListener 'cancel', () =>

            modal.hide()
            dialog.hide()

            if element.restoreState
                element.restoreState()

            callback(false)

        # Support saving the dialog
        dialog.addEventListener 'save', (ev) =>
            detail = ev.detail()
            imageURL = detail.imageURL
            imageSize = detail.imageSize
            imageAttrs = detail.imageAttrs

            if not imageAttrs
                imageAttrs = {}

            imageAttrs.height = imageSize[1]
            imageAttrs.src = imageURL
            imageAttrs.width = imageSize[0]

            if element.type() is 'ImageFixture'
                # Configure the image source against the fixture
                element.src(imageURL)

            else
                # Create the new image
                image = new ContentEdit.Image(imageAttrs)

                # Find insert position
                [node, index] = @_insertAt(element)
                node.parent().attach(image, index)

                # Focus the new image
                image.focus()

            modal.hide()
            dialog.hide()

            callback(true)

            # Dispatch `applied` event
            @dispatchEditorEvent('tool-applied', toolDetail)

        # Show the dialog
        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()

class ContentTools.RestrictedImageDialog extends ContentTools.DialogUI
    constructor: () -> 
        super('Select image')

        if @constructor.IMAGE_GALLERY
            @constructor.IMAGE_GALLERY(this)
    
    mount: () -> 
        super()        
        
        @_addDOMEventListeners()   

    setSource: (imglist) -> 
        tags = imglist.map((img) -> 
            tag = document.createElement('img')
            tag.setAttribute('src', img.src)
            return tag)

        domView = @_domView
        tags.forEach((tag) -> 
            domView.appendChild(tag))

    _addDOMEventListeners: () ->
        super()
        @_domView.addEventListener('click', this._onImageSelect)

    _onImageSelect: (e) => 
        if e.target.tagName.toUpperCase() == 'img'.toUpperCase()
            e.preventDefault()
            
            url = e.target.getAttribute('src')
            size = [200, 200]

            @save(url, size, {})
            
    save: (imageURL, imageSize, imageAttrs) ->
        # Save and insert the current image
        @dispatchEvent(
            @createEvent(
                'save',
                {
                    'imageURL': imageURL,
                    'imageSize': imageSize,
                    'imageAttrs': imageAttrs
                })
            )
    @EXAMPLE_IMAGE_GALLERY = (dialog) ->
        console.log('fetching imglist...')
        setTimeout(() -> 
            console.log('fetched imglist')
            dialog.setSource([
                {src: 'https://www.placecage.com/gif/200/300'},
                {src: 'https://www.placecage.com/gif/200/100'},
                {src: 'https://www.placecage.com/gif/250/250'},
                {src: 'https://www.placecage.com/gif/300/200'},
                {src: 'https://www.placecage.com/gif/400/400'},
                {src: 'https://www.placecage.com/gif/200/200'},
            ])
        , 1 * 1000)