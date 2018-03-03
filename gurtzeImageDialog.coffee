class Gurtze.ImageDialog extends ContentTools.DialogUI
    constructor: () -> 
        super('Select image')

        if Gurtze.IMAGE_GALLERY
            console.log('setting up imggallery')
            Gurtze.IMAGE_GALLERY(this)
    
    mount: () -> 
        super()        

        @_img = document.createElement('img')
        @_img.setAttribute('src', 'https://www.placecage.com/gif/200/300')
        # @constructor.createDiv(['gz-thumb'], null, 'quack')

        @_domView.appendChild(@_img)
        
        @_addDOMEventListeners()   

    setSource: (imglist) -> 
        console.log('set imglist')
    
Gurtze.EXAMPLE_IMAGE_GALLERY = (dialog) ->

    callback = () -> 

    console.log('fetching imglist...')
    setTimeout(() -> 
        console.log('fetched imglist')
        dialog.setSource([
            {src: 'https://www.placecage.com/gif/200/300'},
            {src: 'https://www.placecage.com/gif/200/300'},
            {src: 'https://www.placecage.com/gif/200/300'}
        ])
    , 5 * 1000)