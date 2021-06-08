using System.Collections.Generic;
using WaffleDB;

namespace WaffleDBAPITest
{
    class Program
    {
        static void Main(string[] args)
        {
            List<Waffle> waffleList = WaffleDBAPI.GetAllWaffles();
        }
    }
}
