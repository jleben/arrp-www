#ifndef ARRP_WWW_GENERIC_PRINTER
#define ARRP_WWW_GENERIC_PRINTER

#include <iostream>

namespace arrp_www {

class generic_printer
{
public:
    template <typename T, size_t S>
    void output(T (&a)[S])
    {
        using namespace std;
        print(a);
        cout << endl;
    }

    template <typename T>
    void output(T value)
    {
        print(value);
        cout << endl;
    }

    template <typename T, size_t S>
    void print(T (&a)[S])
    {
        using namespace std;
        cout << "(";
        for (int i = 0; i < S; ++i)
        {
            if (i > 0)
                cout << ",";
            print(a[i]);
        }
        cout << ")";
    }

    template <typename T>
    void print(T a)
    {
        using namespace std;
        cout << a;
    }
};

}

#endif // ARRP_WWW_GENERIC_PRINTER
