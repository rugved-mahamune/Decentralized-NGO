const express = require('express');
const exphbs = require('express-handlebars');
const app = express();


app.engine('hbs', exphbs({defaultLayout: 'home', extname: 'hbs',layoutsDir: __dirname + '/views/layouts/'}));

app.set('view engine', 'hbs');


app.get('/', (req, res) => {

  res.render('body',{title: 'Cool huh!', anyArray: [1,2,3]});
});
//app.get('/js/bootstrap.min.js', function(req, res){ res.sendFile(__dirname + '/js/bootstrap.min.js'); });

app.listen(5000, () => {
    console.log('The web server has started on port 3000');
});
