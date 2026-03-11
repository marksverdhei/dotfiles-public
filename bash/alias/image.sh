
resize_image() {
  convert $2 -filter Point -resize $1 $3
}

alias iresize='resize_image'
