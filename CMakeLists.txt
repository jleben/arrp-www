cmake_minimum_required(VERSION 3.0)

project(arrp-website)

set(URL_PREFIX "" CACHE STRING "")
set(ARRP_SOURCE_DIR "" CACHE PATH "")
set(ARRP_BUILD_DIR "" CACHE PATH "")

if (NOT ARRP_SOURCE_DIR)
    message(FATAL_ERROR "Please set ARRP_SOURCE_DIR!")
endif()

if (NOT ARRP_BUILD_DIR)
    message(FATAL_ERROR "Please set ARRP_BUILD_DIR!")
endif()

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

add_subdirectory(server)


install(DIRECTORY ${CMAKE_BINARY_DIR}/html DESTINATION .)
install(DIRECTORY js DESTINATION .)
install(DIRECTORY css DESTINATION .)
install(DIRECTORY arrp DESTINATION .)
install(FILES ${ARRP_SOURCE_DIR}/cpp/arrp.hpp DESTINATION arrp)
install(FILES ${ARRP_BUILD_DIR}/compiler/arrp DESTINATION arrp
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
)

install(FILES ${CMAKE_BINARY_DIR}/nginx/arrp DESTINATION nginx)
