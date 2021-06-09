using System;
using System.Collections.Generic;
using WaffleDB;

namespace WaffleDBAPITest
{
    class Program
    {
        static int Main()
        {
            PrintfAllWaffles();

            //AddWaffle(); // <--- fails cuz there is no product with that ID

            return 0;
        }

        private static void AddWaffle()
        {
            Waffle newWaffle = new Waffle(7,"BitPaw"); 

            WaffleDBAPI.InsertEntry(newWaffle);
        }

        private static void PrintfAllWaffles()
        {
            List<Waffle> waffleList = WaffleDBAPI.Waffles;

            Console.WriteLine("Waffles");

            foreach (Waffle waffle in waffleList)
            {
                Console.WriteLine(waffle);
            }
        }
    }
}
