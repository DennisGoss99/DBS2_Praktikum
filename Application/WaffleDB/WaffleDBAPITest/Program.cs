using System;
using System.Collections.Generic;
using WaffleDB;

namespace WaffleDBAPITest
{
    class Program
    {
        static int Main()
        {
            PrintfAll(WaffleDBAPI.GetAllWaffles());

            //AddWaffle(); // <--- fails cuz there is no product with that ID
            Console.ReadKey();
            return 0;
        }

        private static void AddWaffle()
        {
            Waffle newWaffle = new Waffle(7,"BitPaw"); 

            WaffleDBAPI.SQLExecuteInsertEntry(newWaffle);
        }

        private static void PrintfAll<T>(List<T> list)
        {
            Console.WriteLine(typeof(T).ToString());

            foreach (T objects in list)
            {
                Console.WriteLine(objects);
            }
        }
    }
}
