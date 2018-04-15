window.addEventListener('load', function() {
    var editor;

    ContentTools.StylePalette.add([
        new ContentTools.Style('Author', 'author', ['p'])
    ]);

    ContentTools.DEFAULT_TOOLS[0].push('restrictedImage')
    ContentTools.DEFAULT_TOOLS[0].push('restrictedLink')

    ContentTools.RestrictedImageDialog.IMAGE_GALLERY = function (dialog) {
        var xhttp = new XMLHttpRequest();
        xhttp.open("GET", "/pics", false);
        xhttp.send();
        dialog.setSource(JSON.parse(xhttp.response));
    };
    
    ContentTools.RestrictedLinkDialog.LINK_LIST = function (dialog) {
        var xhttp = new XMLHttpRequest();
        xhttp.open("GET", "/links", false);
        xhttp.send();
        dialog.setSource(JSON.parse(xhttp.response));
    };

    editor = ContentTools.EditorApp.get();
    editor.init('*[data-editable]', 'data-name');

    editor.addEventListener("saved", function(){
        console.log('saved');
    });
});