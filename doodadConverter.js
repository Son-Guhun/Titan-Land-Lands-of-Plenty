const
    Translator = require('wc3maptranslator'), // require('wc3maptranslator');
    Path = require('path'),
    fs = require('fs');

const filePath = Path.resolve('./development/map/war3map.doo');
const jsonPath = Path.resolve('./development/map/doodads.json');

fs.readFile(filePath, function(err, data) {
    if(err) throw err;

    var doodadResult = new Translator.Doodads.warToJson(data);
    fs.writeFileSync(jsonPath, JSON.stringify(doodadResult.json, null, 4));
});