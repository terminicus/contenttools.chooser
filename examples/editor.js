window.addEventListener('load', function() {
    var editor;

    ContentTools.StylePalette.add([
        new ContentTools.Style('Author', 'author', ['p'])
    ]);

    ContentTools.DEFAULT_TOOLS[0].push('restrictedImage')
    ContentTools.DEFAULT_TOOLS[0].push('restrictedLink')
    ContentTools.RestrictedImageDialog.IMAGE_GALLERY = ContentTools.RestrictedImageDialog.EXAMPLE_IMAGE_GALLERY

    editor = ContentTools.EditorApp.get();
    editor.init('*[data-editable]', 'data-name');

    editor.addEventListener("saved", function(){
        console.log('saved');
    });
});