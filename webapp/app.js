var jsdom = require("jsdom");
const { JSDOM } = jsdom;
const { window } = new JSDOM();
const { document } = (new JSDOM('')).window;
global.document = document;
var $ = jQuery = require('jquery')(window);

const express = require('express');
const exphbs = require('express-handlebars');
const app = express();
var contract = require("truffle-contract");
const Web3 = require('web3');
var Promise = require('promise');
const NGO = require('../build/contracts/NGO.json');
const Primary = require('../build/contracts/Primary.json');
const Entity = require('../build/contracts/Entity.json');
var ngoDeployed;
var entityDeployed;
var entityInstance;
var ngoInstance;
var ngoList;
var primaryDeployed;
var primaryInstance;
var initiativeList;
var entityList;

var provider = new Web3.providers.HttpProvider("http://localhost:7545");

app.engine('hbs', exphbs({defaultLayout: 'home', extname: 'hbs',layoutsDir: __dirname + '/views/layouts/'}));

app.set('view engine', 'hbs');


populateInitiatives = (res) => {
  primaryInstance = contract(Primary);
  primaryInstance.setProvider(provider);
  primaryInstance.deployed().then(value => {
    primaryDeployed = value;
    return primaryDeployed.getActiveInitiativeNames.call();
  }).then(value => {
    initiativeList = value;
    let promises = [];
    for ( i=0;i<value.length;i++){
      promises.push(primaryDeployed.getActiveInitiativeDesc.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeTarget.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeAmt.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeType.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeEL.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeActive.call(value[i]));
      promises.push(primaryDeployed.getActiveInitiativeOwner.call(value[i]));          
    }
    return Promise.all(promises);
  }).then(value => {
    console.log( value);
    var temp = value;
    for(i=0;i<initiativeList.length;i++)
    {
      plac = i*8;
      temp.splice(plac, 0, initiativeList[i]);
    }
    initiativeList = temp;
    console.log( value);
    res.render('initative',{title: 'Cool huh!', initlist: initiativeList});
  }).catch(err => {
    console.log(err);
  });
}

function populateEntities(res) {
  entityInstance = contract(Entity);
  entityInstance.setProvider(provider);
  entityInstance.deployed().then(value => {
    entityDeployed = value;
    return value.getEntitiesList.call();
  }).then(value => {
    entityList = value;
    let promises = [];
    for ( i=0;i<value.length;i++){
      promises.push(entityDeployed.getEntitiyName.call(value[i]));
      promises.push(entityDeployed.getEntitiyType.call(value[i]));
      promises.push(entityDeployed.getEntitiyServed.call(value[i]));
      promises.push(entityDeployed.getEntitiyBlocked.call(value[i]));       
    }
    return Promise.all(promises);
  }).then(value => {
    console.log( value);
    var temp = value;
    for(i=0;i<entityList.length;i++)
    {
      plac = i*5;
      temp.splice(plac, 0, entityList[i]);
    }
    entityList = temp;
    res.render('entity',{title: 'Cool huh!', entity: entityList});
  }).catch(err => {
    console.log(err);
  });
}

app.get('/createNGO', (req, res) => {
  let name = req.query.name;
  let domain = req.query.domain;
  populateInitiatives(res);
});

app.get('/', (req, res) => {
  populateInitiatives(res);
});

app.get('/entities', (req, res) => {
  populateEntities(res);
});

app.get('/js/truffle-contract.js', (req, res) => {
  res.sendFile(__dirname + '/js/truffle-contract.js');
});

app.get('/js/jquery.min.js', (req, res) => {
  res.sendFile(__dirname + '/js/jquery.min.js');
});

app.get('/NGOABI', (req, res) => {
  res.send(NGO);
});

app.get('/PRIMARYABI', (req, res) => {
  res.send(Primary);
});

app.get('/EntityABI', (req, res) => {
  res.send(Entity);
});

app.get('/getNGOABI', (req, res) => {
  primaryInstance = contract(NGO);
  primaryInstance.setProvider(provider);
  primaryInstance.deployed().then(value => {
    res.send({ hello: value});
  });
});

app.get('/js/web3.min.js', (req, res) => {
  res.sendFile(__dirname + '/js/web3.min.js');
});

app.get('/ngos',(req, res) => {
  ngoInstance = contract(NGO);
  ngoInstance.setProvider(provider);
  ngoInstance.deployed().then(value => {
    ngoDeployed = value;
    return value.getNGOsCount();
  }).then(value => {
    ngoList = value;
    var promises = [];
    console.log("addresses",value);
    for ( i in value){
      promises.push(ngoDeployed.getNGOName.call(value[i]));
      promises.push(ngoDeployed.getNGODomain.call(value[i]));
      promises.push(ngoDeployed.getNGOServed.call(value[i]));      
    }
    return Promise.all(promises);
  }).then(value => {
    console.log( value);
    ngoList = value;
    res.render('body',{title: 'Cool huh!', anyArray: ngoList});
  }).catch(err => {
    console.log(err);
  });
});
//app.get('/js/bootstrap.min.js', function(req, res){ res.sendFile(__dirname + '/js/bootstrap.min.js'); });

app.listen(5000, () => {
    console.log('The web server has started on port 5000');
});

/*Promise.all(promises)
    .then((result) => {
      for( i in result ){
        console.log(i)
      }
      res.render('body',{title: 'Cool huh!', anyArray: result});
  });*/