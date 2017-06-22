#include "server.hpp"

#include <thread>
#include <chrono>
#include <iostream>

using namespace Arrp_Web;
using namespace std;

int main(int argc, char * argv[])
{
    options().port = 8000;

    if (argc > 1)
        options().data_path = argv[1];

    if (options().data_path.empty())
    {
        cerr << "Missing option: data path" << endl;
        return 1;
    }

    {
        Server server;

        for(;;)
            this_thread::sleep_for(chrono::seconds(1));
    }

    return 0;
}
