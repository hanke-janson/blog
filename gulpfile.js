var gulp = require('gulp');

//Plugins模块获取
var minifycss = require('gulp-minify-css');
var uglify = require('gulp-uglify');
var htmlmin = require('gulp-htmlmin');
var htmlclean = require('gulp-htmlclean');
//压缩css
gulp.task('minify-css', async()=>{
    await gulp.src('./public/**/*.css')
        .pipe(minifycss())
        .pipe(gulp.dest('./public'));
});
//压缩html
gulp.task('minify-html', async()=>{
    await gulp.src('./public/**/*.html')
    .pipe(htmlclean())
    .pipe(htmlmin({
    removeComments: true,
    minifyJS: true,
    minifyCSS: true,
    minifyURLs: true,
    }))
.pipe(gulp.dest('./public'))
});
//压缩js 不压缩min.js
gulp.task('minify-js', async()=>{
    await gulp.src(['./public/**/*.js', '!./public/**/*.min.js'])
    .pipe(uglify())
    .pipe(gulp.dest('./public'));
});
// 执行 gulp 命令时执行的任务
gulp.task('default', gulp.parallel('minify-html', 'minify-css', 'minify-js', async()=>{
  // Do something after a, b, and c are finished.
}));
 
