cmake_minimum_required(VERSION 3.0)

project(arrp-website)

set(URL_PREFIX "" CACHE STRING "")

#add_subdirectory(pug)

function(generate_nginx_config)
    set(FILE_PREFIX ${CMAKE_INSTALL_PREFIX})
    configure_file(nginx/arrp.template nginx/arrp)
endfunction()

generate_nginx_config()

function(generate_systemd_config)
    configure_file(systemd/arrp-website.service.template systemd/arrp-website.service)
endfunction()

# generate_systemd_config()

#install(DIRECTORY ${CMAKE_BINARY_DIR}/html DESTINATION .)
#install(DIRECTORY js DESTINATION .)
#install(DIRECTORY css DESTINATION .)
#install(DIRECTORY arrp DESTINATION .)
#install(DIRECTORY DESTINATION request)
#install(FILES ${CMAKE_BINARY_DIR}/nginx/arrp DESTINATION /etc/nginx/sites-available)
#install(CODE "execute_process(COMMAND ln -s -f /etc/nginx/sites-available/arrp /etc/nginx/sites-enabled)")
#install(FILES ${CMAKE_BINARY_DIR}/systemd/arrp-website.service DESTINATION /etc/systemd/system)
#install(CODE "execute_process(COMMAND chown -R www-data:www-data ${CMAKE_INSTALL_PREFIX}/request)")

add_subdirectory(server)
