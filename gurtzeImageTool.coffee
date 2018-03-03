class Gurtze.ImageTool extends ContentTools.Tools.Image
    # Register the tool with the toolshelf
    ContentTools.ToolShelf.stow(@, 'gurtzeImage')

    # The tooltip and icon modifier CSS class for the tool
    @label = 'Gurtze Image'
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
        dialog = new Gurtze.ImageDialog()

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