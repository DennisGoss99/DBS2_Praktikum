using System;
using System.Collections.Generic;
using WaffleDB;

namespace WaffleDBAPITest
{
    class Program
    {
        static int Main()
        {
            PrintAllTables();

            //AddWaffle(); // <--- fails cuz there is no product with that ID
            Console.ReadKey();
            return 0;
        }

        private static void AddWaffle()
        {
            Waffle newWaffle = new Waffle(7,"BitPaw"); 

            WaffleDBAPI.SQLExecuteInsertEntry(newWaffle);
        }

        private static void PrintAllTables()
        {
            PrintfCompleteList(WaffleDBAPI.GetAllAdditions());
            PrintfCompleteList(WaffleDBAPI.GetAllIngredients());
            PrintfCompleteList(WaffleDBAPI.GetAllInventorys());
            PrintfCompleteList(WaffleDBAPI.GetAllNutritionInformations());
            PrintfCompleteList(WaffleDBAPI.GetAllPersonalNotifications());
            PrintfCompleteList(WaffleDBAPI.GetAllProducts());
            PrintfCompleteList(WaffleDBAPI.GetAllProductOrders());
            PrintfCompleteList(WaffleDBAPI.GetAllWaffles());
            PrintfCompleteList(WaffleDBAPI.GetAllWaffleIngredients());
            PrintfCompleteList(WaffleDBAPI.GetAllWaffleOrders());
            PrintfCompleteList(WaffleDBAPI.GetAllWaffleStores());
        }

        private static void PrintfCompleteList<T>(List<T> list)
        {
            Console.WriteLine("---------------------------------------------------------");
            Console.WriteLine("Parsing <" + typeof(T).ToString() + ">");
            Console.WriteLine("---------------------------------------------------------");

            if(list == null)
            {
                Console.WriteLine("List is NULL! Maybe there was something wrong while fetching the data.");
            }
            else
            {
                if(list.Count == 0)
                {
                    Console.WriteLine("<No Data>");
                }
                else
                {
                    foreach (T objects in list)
                    {
                        Console.WriteLine(objects);
                    }
                }
            }     

            Console.WriteLine("---------------------------------------------------------\n\n");
        }
    }
}
