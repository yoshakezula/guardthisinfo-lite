var require = {
  paths: {
    jquery: "libs/jquery/jquery-2.0.3.min",
    app: 'app',
    modernizr: 'libs/modernizr.custom.min',
    bootstrap: 'libs/bootstrap.min.js'
  },

  shim: {
    bootstrap: ['jquery'],
    modernizr: {
      exports: 'Modernizr'
    },
    app: ['modernizr']
  },

  preserveLicenseComments: false,
  // waitSeconds: 15
}