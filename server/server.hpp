#pragma once

#include <Poco/URI.h>
#include <Poco/Net/HTTPServer.h>
#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPRequestHandlerFactory.h>

#include <stdexcept>
#include <atomic>
#include <mutex>

namespace Arrp_Web {

using Poco::Net::HTTPServer;
using Poco::Net::HTTPServerParams;
using Poco::Net::HTTPServerRequest;
using Poco::Net::HTTPServerResponse;
using Poco::Net::HTTPRequestHandler;
using Poco::Net::HTTPRequestHandlerFactory;
using std::string;
using std::atomic;
using std::mutex;

class Options
{
public:
    int port = 8000;
    string data_path;
    int max_log_count = 100;
};

Options & options();

class Server
{
public:
    Server();

private:
    static HTTPServerParams * params();

    HTTPServer d_server;
};

class Request_Handler_Factory : public HTTPRequestHandlerFactory
{
public:
    Request_Handler_Factory();

private:
    HTTPRequestHandler * createRequestHandler
    (const HTTPServerRequest & request) override;

    mutex d_mutex;
    int d_max_ids = 10;
    int d_next_id = 0;
};

class Play_Handler : public HTTPRequestHandler
{
public:
    struct Error : public std::exception
    {
        string msg;
        Error(const string & msg) : msg(msg) {}
        const char * what() const noexcept override { return msg.c_str(); }
    };

    Play_Handler(int id);

private:
    int d_id = 0;
    string d_log_dir;

    void handleRequest
    (HTTPServerRequest & request,
     HTTPServerResponse & response)
    override;

    void play(HTTPServerRequest & request,
              HTTPServerResponse & response,
              const Poco::URI &);
    void write_arrp_code(HTTPServerRequest & request);
    void compile_arrp_code(HTTPServerResponse & response);
    void compile_cpp_code(HTTPServerResponse & response);
    void run_program(HTTPServerResponse & response, int out_count);
};

}
