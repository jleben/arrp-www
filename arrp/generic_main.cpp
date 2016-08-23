#include "kernel.cpp"
#include "generic_printer.hpp"

int main()
{
    const int reps = 10;

    auto d = new arrp_www::generic_printer;
    auto k = new kernel::state<arrp_www::generic_printer>;
    k->io = d;

    k->initialize();
    for (int i = 0; i < reps; ++i)
    {
        k->process();
    }

    delete k;
    delete d;
}
