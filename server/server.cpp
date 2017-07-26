#include "server.hpp"

#include <Poco/Net/HTTPServerParams.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>
#include <Poco/URI.h>
#include <iostream>
#include <sstream>
#include <fstream>
#include <unordered_map>

using namespace std;

namespace Arrp_Web {

Options & options()
{
    static Options options;
    return options;
}

Server::Server():
    d_server(new Request_Handler_Factory, options().port, params())
{
    d_server.start();
}

Poco::Net::HTTPServerParams * Server::params()
{
    auto params = new HTTPServerParams;
    params->setMaxThreads(1);
}

Request_Handler_Factory::Request_Handler_Factory()
{
    d_max_ids = options().max_log_count;
}

HTTPRequestHandler * Request_Handler_Factory::createRequestHandler
(const HTTPServerRequest &)
{
    lock_guard<mutex> guard(d_mutex);

    int id = d_next_id;

    d_next_id = (d_next_id + 1) % d_max_ids;

    return new Play_Handler(id);
}

Play_Handler::Play_Handler(int id):
    d_id(id)
{
    d_log_dir = "log/" + to_string(id);
}

void Play_Handler::handleRequest(HTTPServerRequest &request, HTTPServerResponse &response)
{
    using namespace Poco::Net;

    cerr << "Request: " << request.getMethod() << " " << request.getURI() << endl;

    Poco::URI uri(request.getURI());

    if (uri.getPath() == "/play/post")
    {
        if (request.getMethod() == "POST")
        {
            try
            {
                play(request, response, uri);
            }
            catch (Error & e)
            {
                cerr << "Error: " << e.what() << endl;
                response.setStatusAndReason
                        (HTTPResponse::HTTP_INTERNAL_SERVER_ERROR, e.what());
                response.send();
            }
        }
        else
        {
            response.setStatus(HTTPResponse::HTTP_METHOD_NOT_ALLOWED);
            response.send();
        }
    }
    else
    {
        response.setStatus(HTTPResponse::HTTP_NOT_FOUND);
        response.send();
    }

    if (!response.sent())
    {
        response.setStatus(HTTPResponse::HTTP_INTERNAL_SERVER_ERROR);
        response.send();
    }
}

void Play_Handler::play(HTTPServerRequest & request,
                        HTTPServerResponse & response,
                        const Poco::URI & uri)
{
    using namespace Poco::Net;

    auto query_list = uri.getQueryParameters();
    unordered_map<string,string> queries;
    for (auto & query : query_list)
    {
        queries[query.first] = query.second;
    }

    int out_count = 10;
    auto & out_count_param = queries["out_count"];
    if (!out_count_param.empty())
    {
        out_count = stoi(out_count_param);
    }

    if (out_count > 10000)
    {
        response.setStatus(HTTPResponse::HTTP_BAD_REQUEST);
        response.send();
    }

    // Make log dir

    {
        auto cmd = "mkdir -p " + d_log_dir;
        int result = system(cmd.c_str());
        if (result != 0)
        {
            throw Error("Failed to create log dir: " + d_log_dir);
        }
    }

    write_arrp_code(request);
    compile_arrp_code(response);
    compile_cpp_code(response);
    run_program(response, out_count);
}

void Play_Handler::write_arrp_code(HTTPServerRequest & request)
{
    using namespace Poco::Net;

    auto & in = request.stream();

    ofstream code_file("play.arrp");
    ofstream code_log_file(d_log_dir + "/play.arrp");

    string buffer(1024, 0);

    size_t max_file_size = 1024 * 1024;
    size_t file_size = 0;

    while(in && code_file && file_size < max_file_size)
    {
        in.read(&buffer[0], 1024);

        size_t count = in.gcount();
        if (count == 0)
            break;

        code_file.write(&buffer[0], count);
        code_log_file.write(&buffer[0], count);

        file_size += count;
    }

    if (in.fail() && !in.eof())
    {
        throw Error("Failed to read request body.");
    }
    if (code_file.fail())
    {
        throw Error("Failed to write code file.");
    }
    if (code_log_file.fail())
    {
        throw Error("Failed to write code file to log directory.");
    }
}

void Play_Handler::compile_arrp_code(HTTPServerResponse & response)
{
    using namespace Poco::Net;

    ostringstream cmd;
    cmd << options().data_path << "/bin/arrp"
        << " play.arrp"
        << " --cpp arrp_program"
        << " --cpp-namespace arrp"
        << " 2> arrp.out";

    cerr << "Executing: " << cmd.str() << endl;

    int status = system(cmd.str().c_str());
    if (status == 0)
        return;

    response.setStatus(HTTPResponse::HTTP_OK);

    ifstream arrp_out("arrp.out");

    auto & body = response.send();
    body << "Arrp compilation failed:" << endl;
    body << arrp_out.rdbuf();

    throw Error("Arrp compilation failed.");
}

void Play_Handler::compile_cpp_code(HTTPServerResponse & response)
{
    using namespace Poco::Net;

    ostringstream cmd;
    cmd << "g++ -std=c++17"
        << " -I" << options().data_path << "/include"
        << " -I."
        << " " << options().data_path << "/generic_main.cpp"
        << " -o arrp_program"
        << " 2> cpp.out";

    cerr << "Executing: " << cmd.str() << endl;

    int status = system(cmd.str().c_str());
    if (status == 0)
        return;

    response.setStatus(HTTPResponse::HTTP_OK);

    ifstream cpp_out("cpp.out");

    auto & body = response.send();
    body << "C++ compilation failed:" << endl;
    body << cpp_out.rdbuf();

    throw Error("C++ compilation failed.");
}

void Play_Handler::run_program(HTTPServerResponse & response, int out_count)
{
    using namespace Poco::Net;

    ostringstream cmd;
    cmd << "./arrp_program "
        << out_count
        << " > program.out";

    cerr << "Executing: " << cmd.str() << endl;

    int status = system(cmd.str().c_str());

    response.setStatus(HTTPResponse::HTTP_OK);

    auto & body = response.send();

    if (status != 0)
        body << "Execution failed:" << endl;

    ifstream program_out("program.out");
    body << program_out.rdbuf();

    if (status != 0)
        throw Error("Program execution failed.");
}

}
