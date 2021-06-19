using System;
using System.Collections.Generic;
using WaffleDB;

namespace WaffleDBAPITest
{
    class Program
    {
        static int Main()
        {
            //int wurst = WaffleDBAPI.FetchOrderTime(1);

            BuyAddition();

            PrintAllTables();

            //BuildCustomWaffle(); // OK
            //BuyStuff(); // OK

            Console.ReadKey();
            return 0;
        }

        private static void BuyAddition()
        {
            ShoppingCart shoppingCart = new ShoppingCart();

            // cant implemetnt this

            shoppingCart.ProductOrderList.Add(new KeyValuePair<IProduct, int>(new ProductAddition(1), 1));

            Console.WriteLine("Buying addition...");

            shoppingCart.FinishOrder(1);

            Console.WriteLine("Bought addition!");
        }

        private static void BuyStuff()
        {
            ShoppingCart shoppingCart = new ShoppingCart();

            // cant implemetnt this

            //shoppingCart.ProductOrderList.Add(new KeyValuePair<int, int>(1, 1));
            //shoppingCart.ProductOrderList.Add(new KeyValuePair<int, int>(2, 2));
            //shoppingCart.ProductOrderList.Add(new KeyValuePair<int, int>(3, 5));

            shoppingCart.FinishOrder(1);
        }

        private static void BuildCustomWaffle()
        {
            string waffleName = "BitPaws_Waffel";
            List<KeyValuePair<int, int>> ingredientList = new List<KeyValuePair<int, int>>();


            ingredientList.Add(new KeyValuePair<int, int>(1, 5));
            ingredientList.Add(new KeyValuePair<int, int>(2, 3));
            ingredientList.Add(new KeyValuePair<int, int>(3, 10));
            ingredientList.Add(new KeyValuePair<int, int>(4, 50));

            ProductWaffle productWaffle = WaffleDBAPI.CreateCustomWaffle(waffleName, ingredientList);

            Console.WriteLine("Waffle created <" + productWaffle.ToString() + ">");
        }

        private static void PrintAllTables()
        {
            PrintfCompleteList(WaffleDBAPI.GetAllProductAdditions());
            PrintfCompleteList(WaffleDBAPI.GetAllProductWaffles());

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
