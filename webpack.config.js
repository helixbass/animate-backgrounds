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
    'animejs-hooks': {
      commonjs: 'animejs-hooks',
      commonjs2: 'animejs-hooks',
      amd: 'animejs-hooks',
      root: 'anime',
    },
    // tinycolor2: {
    //   commonjs: 'tinycolor2',
    //   commonjs2: 'tinycolor2',
    //   amd: 'animejs',
    //   root: 'tinycolor',
    // },
  },
}
