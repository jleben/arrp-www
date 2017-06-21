cmake_minimum_required(VERSION 3.0)

project(arrp-website)

set(URL_PREFIX "" CACHE STRING "")

add_custom_command (
    OUTPUT html/play.html
    COMMAND pug
        "${CMAKE_SOURCE_DIR}/pug/pages"
        -O "{base_url: '${URL_PREFIX}'}"
        --out "${CMAKE_BINARY_DIR}/html"
    VERBATIM
)

add_custom_target(pug_to_html ALL DEPENDS html/play.html)

function(generate_nginx_config)
    set(FILE_PREFIX ${CMAKE_INSTALL_PREFIX})
    configure_file(nginx/arrp.template nginx/arrp)
endfunction()

generate_nginx_config()

install(DIRECTORY arrp DESTINATION .)
install(DIRECTORY js DESTINATION .)
install(DIRECTORY css DESTINATION .)
install(DIRECTORY ${CMAKE_BINARY_DIR}/html DESTINATION .)
install(FILES ${CMAKE_BINARY_DIR}/nginx/arrp DESTINATION nginx)
