var path = require('path')
module.exports = {
  entry: {
    jquery: './src/jquery.coffee',
    anime: './src/anime.coffee',
  },
  module: {
    loaders: [
      {
        test: /\.coffee$/,
        loader: ['babel-loader', 'coffee-loader'],
      },
    ],
  },
  output: {
    path: __dirname,
    filename: 'animate-backgrounds.[name].js',
    libraryTarget: 'umd',
  },
  resolve: {
    extensions: ['.coffee', '.js']
  },
  externals: {
    jquery: {
      commonjs: 'jquery',
      commonjs2: 'jquery',
      amd: 'jquery',
      root: 'jQuery',
    },
    'jquery-color': {
      commonjs: 'jquery',
      commonjs2: 'jquery',
      amd: 'jquery',
      root: 'jQuery',
    },
    animejs: {
      commonjs: 'animejs',
      commonjs2: 'animejs',
      amd: 'animejs',
      root: 'anime',
    },
  },
}
