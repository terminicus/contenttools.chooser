class ContentTools.Tools.RestrictedImageTool extends ContentTools.Tools.Image
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
    
    mount: () -> 
        super()        
        
        @_addDOMEventListeners()   

        if @constructor.IMAGE_GALLERY
            @constructor.IMAGE_GALLERY(this)

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

class ContentTools.Tools.Link extends ContentTools.Tools.Bold

    # Insert/Remove a link.

    ContentTools.ToolShelf.stow(@, 'restrictedLink')

    @label = 'Link'
    @icon = 'link'
    @tagName = 'a'

    @getAttr: (attrName, element, selection) ->
        # Get an attribute for the element and selection

        # Images
        if element.type() is 'Image'
            if element.a
                return element.a[attrName]

        # Fixtures
        else if element.isFixed() and element.tagName() is 'a'
            return element.attr(attrName)

        # Text
        else
            # Find the first character in the selected text that has an `a` tag
            # and return the named attributes value.
            [from, to] = selection.get()
            selectedContent = element.content.slice(from, to)
            for c in selectedContent.characters
                if not c.hasTags('a')
                    continue

                for tag in c.tags()
                    if tag.name() == 'a'
                        return tag.attr(attrName)

        return ''

    @canApply: (element, selection) ->
        # Return true if the tool can be applied to the current
        # element/selection.
        if element.type() is 'Image'
            return true
        else if element.isFixed() and element.tagName() is 'a'
            return true
        else
            # Must support content
            unless element.content
                return false

            # A selection must exist
            if not selection
                return false

            # If the selection is collapsed then it must be within an existing
            # link.
            if selection.isCollapsed()
                character = element.content.characters[selection.get()[0]]
                if not character or not character.hasTags('a')
                    return false

            return true

    @isApplied: (element, selection) ->
        # Return true if the tool is currently applied to the current
        # element/selection.
        if element.type() is 'Image'
            return element.a
        else if element.isFixed() and element.tagName() is 'a'
            return true
        else
            return super(element, selection)

    @apply: (element, selection, callback) ->
        # Dispatch `apply` event
        toolDetail = {
            'tool': this,
            'element': element,
            'selection': selection
            }
        if not @dispatchEditorEvent('tool-apply', toolDetail)
            return

        applied = false

        # Prepare text elements for adding a link
        if element.type() is 'Image'
            # Images
            rect = element.domElement().getBoundingClientRect()

        else if element.isFixed() and element.tagName() is 'a'
            # Fixtures
            rect = element.domElement().getBoundingClientRect()

        else
            # If the selection is collapsed then we need to select the entire
            # entire link.
            if selection.isCollapsed()

                # Find the bounds of the link
                characters = element.content.characters
                starts = selection.get(0)[0]
                ends = starts

                while starts > 0 and characters[starts - 1].hasTags('a')
                    starts -= 1

                while ends < characters.length and characters[ends].hasTags('a')
                    ends += 1

                # Select the link in full
                selection = new ContentSelect.Range(starts, ends)
                selection.select(element.domElement())

            # Text elements
            element.storeState()

            # Add a fake selection wrapper to the selected text so that it
            # appears to be selected when the focus is lost by the element.
            selectTag = new HTMLString.Tag('span', {'class': 'ct--puesdo-select'})
            [from, to] = selection.get()
            element.content = element.content.format(from, to, selectTag)
            element.updateInnerHTML()

            # Measure a rectangle of the content selected so we can position the
            # dialog centrally.
            domElement = element.domElement()
            measureSpan = domElement.getElementsByClassName('ct--puesdo-select')
            rect = measureSpan[0].getBoundingClientRect()

        # Set-up the dialog
        app = ContentTools.EditorApp.get()

        # Modal
        modal = new ContentTools.ModalUI(transparent=true, allowScrolling=true)

        # When the modal is clicked on the dialog should close
        modal.addEventListener 'click', () ->
            @unmount()
            dialog.hide()

            if element.content
                # Remove the fake selection from the element
                element.content = element.content.unformat(from, to, selectTag)
                element.updateInnerHTML()

                # Restore the selection
                element.restoreState()

            callback(applied)

            # Dispatch `applied` event
            if applied
                ContentTools.Tools.Link.dispatchEditorEvent(
                    'tool-applied',
                    toolDetail
                    )

        # Dialog
        dialog = new ContentTools.RestrictedLinkDialog(
            @getAttr('href', element, selection),
            @getAttr('target', element, selection)
            )

        # Get the scroll position required for the dialog
        [scrollX, scrollY] = ContentTools.getScrollPosition()

        # dialog.position([
        #     rect.left + (rect.width / 2) + scrollX,
        #     rect.top + (rect.height / 2) + scrollY
        #     ])

        dialog.addEventListener 'save', (ev) ->
            detail = ev.detail()

            applied = true

            # Add the link
            if element.type() is 'Image'

                # Images
                #
                # Note: When we add/remove links any alignment class needs to be
                # moved to either the link (on adding a link) or the image (on
                # removing a link). Alignment classes are mutually exclusive.
                alignmentClassNames = [
                    'align-center',
                    'align-left',
                    'align-right'
                    ]

                if detail.href
                    element.a = {href: detail.href}

                    if element.a
                        element.a.class = element.a['class']

                    if detail.target
                        element.a.target = detail.target

                    for className in alignmentClassNames
                        if element.hasCSSClass(className)
                            element.removeCSSClass(className)
                            element.a['class'] = className
                            break

                else
                    linkClasses = []
                    if element.a['class']
                        linkClasses = element.a['class'].split(' ')
                    for className in alignmentClassNames
                        if linkClasses.indexOf(className) > -1
                            element.addCSSClass(className)
                            break
                    element.a = null

                element.unmount()
                element.mount()

            else if element.isFixed() and element.tagName() is 'a'
                # Fixtures
                element.attr('href', detail.href)

            else
                # Text elements

                # Clear any existing link
                element.content = element.content.unformat(from, to, 'a')

                # If specified add the new link
                if detail.href
                    a = new HTMLString.Tag('a', detail)
                    element.content = element.content.format(from, to, a)
                    element.content.optimize()

                element.updateInnerHTML()

            # Make sure the element is marked as tainted
            element.taint()

            # Close the modal and dialog
            modal.dispatchEvent(modal.createEvent('click'))

        app.attach(modal)
        app.attach(dialog)
        modal.show()
        dialog.show()

class ContentTools.RestrictedLinkDialog extends ContentTools.DialogUI

    # An anchored dialog to support inserting/modifying a link

    # The target that will be set by the link tool if the open in new window
    # option is selected.
    NEW_WINDOW_TARGET = '_blank'

    constructor: (href='', target='') ->
        super()

        # The initial value to set the href and target attribute
        # of the link as (e.g if we're editing a link).
        @_href = href
        @_target = target

    mount: () ->
        # Mount the widget
        super()

        # Create the input element for the link
        @_domInput = document.createElement('input')
        @_domInput.setAttribute('class', 'ct-anchored-dialog__input')
        @_domInput.setAttribute('name', 'href')
        @_domInput.setAttribute(
            'placeholder',
            ContentEdit._('Enter a link') + '...'
            )
        @_domInput.setAttribute('type', 'text')
        @_domInput.setAttribute('value', @_href)
        @_domElement.appendChild(@_domInput)

        # Create a toggle button to allow users to toogle between no target and
        # TARGET (open in a new window).
        @_domTargetButton = @constructor.createDiv([
            'ct-anchored-dialog__target-button'])
        @_domElement.appendChild(@_domTargetButton)

        # Check if the new window target has already been set for the link
        if @_target == NEW_WINDOW_TARGET
            ContentEdit.addCSSClass(
                @_domTargetButton,
                'ct-anchored-dialog__target-button--active'
            )

        # Create the confirm button
        @_domButton = @constructor.createDiv(['ct-anchored-dialog__button'])
        @_domElement.appendChild(@_domButton)

        # Add interaction handlers
        @_addDOMEventListeners()

    save: () ->
        # Save the link. This method triggers the save method against the dialog
        # allowing the calling code to listen for the `save` event and manage
        # the outcome.

        if not @isMounted()
            @dispatchEvent(@createEvent('save'))
            return

        detail = {href: @_domInput.value.trim()}
        if @_target
            detail.target = @_target

        @dispatchEvent(@createEvent('save', detail))

    show: () ->
        # Show the widget
        super()

        # Once visible automatically give focus to the link input
        @_domInput.focus()

        # If a there's an intially value then select it so it can be easily
        # replaced.
        if @_href
            @_domInput.select()

    unmount: () ->
        # Unmount the component from the DOM

        # Unselect any content
        if @isMounted()
            @_domInput.blur()

        super()

        @_domButton = null
        @_domInput = null

    # Private methods

    _addDOMEventListeners: () ->
        # Add event listeners for the widget

        # Add support for saving the link whenever the `return` key is pressed
        # or the button is selected.

        # Input
        @_domInput.addEventListener 'keypress', (ev) =>
            if ev.keyCode is 13
                @save()

        # Toggle the target attribute for the link ('' or TARGET)
        @_domTargetButton.addEventListener 'click', (ev) =>
            ev.preventDefault()

            # No target
            if @_target == NEW_WINDOW_TARGET
                @_target = ''
                ContentEdit.removeCSSClass(
                    @_domTargetButton,
                    'ct-anchored-dialog__target-button--active'
                )

            # Target TARGET
            else
                @_target = NEW_WINDOW_TARGET
                ContentEdit.addCSSClass(
                    @_domTargetButton,
                    'ct-anchored-dialog__target-button--active'
                )

        # Button
        @_domButton.addEventListener 'click', (ev) =>
            ev.preventDefault()
            @save()
