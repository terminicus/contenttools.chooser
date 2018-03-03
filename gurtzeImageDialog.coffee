class Gurtze.ImageDialog extends ContentTools.DialogUI
    constructor: () -> 
        super('Select image')

        if Gurtze.IMAGE_GALLERY
            Gurtze.IMAGE_GALLERY(this)
    
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
        console.log(e)
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


    
Gurtze.EXAMPLE_IMAGE_GALLERY = (dialog) ->
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