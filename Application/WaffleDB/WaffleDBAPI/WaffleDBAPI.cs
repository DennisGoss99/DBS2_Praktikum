using Dapper;
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using System.Linq;

namespace WaffleDB
{
    public class WaffleDBAPI 
    {
        private static string _ip { get => "127.0.0.1"; }
        private static string _dataBaseName { get => "waffleDB"; }
        private static string _connectionString { get => "Server=" + _ip + ";Database=" + _dataBaseName + ";Uid=root;Pwd=;"; }
               

        private static List<T> TableFetchAll<T>()
        {
            string tableName = typeof(T).ToString(); 
            string sqlCommand = "SELECT * FROM " + tableName;
            List<T> objectList = null;

            try
            {
                using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
                {
                    objectList = mysqlConnection.Query<T>(sqlCommand).ToList();
                }
            }
            catch (System.Exception)
            {
                // Do nothing
            }       

            return objectList;
        }
        
        public static ProductWaffle GetProductWaffle(int waffleID)
        {
            ProductWaffle productWaffle = new ProductWaffle();

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                productWaffle.WaffleElement = mysqlConnection.Query<Waffle>("select * from waffle where idWaffle = " + waffleID).First();
                productWaffle.ProductElement = mysqlConnection.Query<Product>("select * from product where idProduct = " + waffleID).First();
            }

            return productWaffle;
        }

        public static void SQLExecuteInsertEntry(IDataBaseTable dataBaseTable)
        {
            string sqlCommand = dataBaseTable.InsertCommand;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }

        public static void SQLExecuteCommand(string sqlCommand)
        {
            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }

        public static void SQLExecuteUpdateEntry(IDataBaseTable dataBaseTable)
        {
            string sqlCommand = dataBaseTable.UpdateCommand;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }

        public static List<Product> GetAllProducts()
        {
            return TableFetchAll<Product>();
        }
        public static List<Addition> GetAllAdditions()
        {
            return TableFetchAll<Addition>();
        }
        public static List<Waffle> GetAllWaffles()
        {
            return TableFetchAll<Waffle>();
        }
        public static List<WaffleIngredient> GetAllWaffleIngredients()
        {
            return TableFetchAll<WaffleIngredient>();
        }
        public static List<Ingredient> GetAllIngredients()
        {
            return TableFetchAll<Ingredient>();
        }
        public static List<NutritionalInformation> GetAllNutritionInformations()
        {
            return TableFetchAll<NutritionalInformation>();
        }
        public static List<Inventory> GetAllInventorys()
        {
            return TableFetchAll<Inventory>();
        }
        public static List<WaffleStore> GetAllWaffleStores()
        {
            return TableFetchAll<WaffleStore>();
        }
        public static List<PersonalNotification> GetAllPersonalNotifications()
        {
            return TableFetchAll<PersonalNotification>();
        }
        public static List<WaffleOrder> GetAllWaffleOrders()
        {
            return TableFetchAll<WaffleOrder>();
        }
        public static List<ProductOrder> GetAllProductOrders()
        {
            return TableFetchAll<ProductOrder>();
        }
    }
}
