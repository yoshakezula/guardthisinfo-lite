var require = {
  paths: {
    jquery: "libs/jquery-2.0.3.min",
    app: 'app',
    modernizr: 'libs/modernizr.custom.min',
    bootstrap: 'libs/bootstrap.min'
  },

  shim: {
    bootstrap: ['jquery'],
    modernizr: {
      exports: 'Modernizr'
    },
    app: ['modernizr', 'jquery', 'bootstrap']
  },

  preserveLicenseComments: false,
  // waitSeconds: 15
}