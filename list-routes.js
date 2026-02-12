const app = require('./app');

function print(path, layer) {
    if (layer.route) {
        layer.route.stack.forEach(print.bind(null, path.concat(split(layer.route.path))))
    } else if (layer.name === 'router' && layer.handle.stack) {
        layer.handle.stack.forEach(print.bind(null, path.concat(split(layer.regexp))))
    } else if (layer.method) {
        console.log('%s /%s', layer.method.toUpperCase(), path.concat(split(layer.regexp || layer.route.path)).filter(Boolean).join('/'))
    }
}

function split(thing) {
    if (typeof thing === 'string') {
        return thing.split('/')
    } else if (thing.fast_slash) {
        return ''
    } else {
        var str = thing.toString()
            .replace('\\/?', '')
            .replace('(?=\\/|$)', '')
            .replace(/\\\//g, '/')
            .replace('(?:/(?=$))?$', '')
            .replace('^', '')
            .replace('$', '')
        return str.split('/')
    }
}

console.log('--- REGISTERED ROUTES ---');
app._router.stack.forEach(print.bind(null, []))
