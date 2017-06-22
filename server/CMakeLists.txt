
add_executable (server
    main.cpp
    server.cpp
)

target_link_libraries (server
    PocoFoundation
    PocoNet
)

install(TARGETS server DESTINATION server)
