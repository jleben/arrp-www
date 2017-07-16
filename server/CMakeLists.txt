
add_executable (arrp-server
    main.cpp
    server.cpp
)

target_link_libraries (arrp-server
    PocoFoundation
    PocoNet
)

install(TARGETS arrp-server DESTINATION server)
