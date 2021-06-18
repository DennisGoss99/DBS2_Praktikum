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


        private static List<T> TableFetchAll<T>(string customSelectSQL)
        {
            List<T> objectList = null;

            try
            {
                using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
                {
                    objectList = mysqlConnection.Query<T>(customSelectSQL).ToList();
                }
            }
            catch (System.Exception)
            {
                // Do nothing
            }

            return objectList;
        }

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

        public static void SQLExecuteCommand(string sqlCommand)
        {
            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                mysqlConnection.Execute(sqlCommand);
            }
        }

        public static int SQLGetInt(string sqlCommand)
        {
            int result = -1;

            using (MySqlConnection mysqlConnection = new MySqlConnection(_connectionString))
            {
                result = mysqlConnection.QueryFirst<int>(sqlCommand);
            }

            return result;
        }

        public static void SQLExecuteInsertEntry(IDataBaseTable dataBaseTable)
        {
            string sqlCommand = dataBaseTable.InsertCommand;

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



        /// <summary>
        /// Create a waffle and push it to the Database.
        /// </summary>
        /// <param name="waffleName">Name of the Waffle</param>
        /// <param name="ingredientList">List of ingredients (IngredientID, Amount). Can't be empty.</param>
        /// <returns></returns>
        public static Waffle CreateCustomWaffle(string waffleName, List<KeyValuePair<int, int>> ingredientList, string creatorName = "Unkown")
        {
            if (ingredientList.Count == 0)
                return null;

            //--- Create new nutritionalInformation ---------------------------
            int nutritionalInformationID = SQLGetInt("select max(idNuIn) from NutritionalInformation") + 1;
            NutritionalInformation nutritionalInformation = new NutritionalInformation(nutritionalInformationID);

            SQLExecuteInsertEntry(nutritionalInformation);
            //-----------------------------------------------------------------

            //--- Create new product ------------------------------------------
            int productID = SQLGetInt("select max(idProduct) from Product") + 1;
            Product product = new Product(productID, nutritionalInformationID, -1, waffleName);

            SQLExecuteInsertEntry(product);
            //-----------------------------------------------------------------

            //--- Create new wallfe -------------------------------------------
            int waffleID = productID;
            Waffle waffle = new Waffle(waffleID, creatorName);

            SQLExecuteInsertEntry(waffle);
            //-----------------------------------------------------------------


            //--- Add all ingredients -----------------------------------------
            foreach (var item in ingredientList)
            {
                int ingredientID = item.Key;
                int amount = item.Value;

                WaffleIngredient waffleIngredient = new WaffleIngredient(ingredientID, waffleID, amount);

                SQLExecuteInsertEntry(waffleIngredient);
            }
            //-----------------------------------------------------------------

            return waffle;
        }

        public static List<KeyValuePair<Ingredient, int>> GetIngredientsWithAmount()
        {
            List<KeyValuePair<Ingredient, int>> ingredientsWithAmounts = new List<KeyValuePair<Ingredient, int>>();

            // Ingredient join inventory -> store id &  amount & access

            return ingredientsWithAmounts;
        }

        public static WaffleOrder CreateNewWaffleOrder(int idStore)
        {
            int getNextID = SQLGetInt("select max(idOrder) from WaffleOrder") + 1;

            WaffleOrder waffleOrder = new WaffleOrder(getNextID, idStore, 0, 0);

            return waffleOrder;
        }

        public static List<ProductWaffle> GetAllProductWaffles()
        {
            return TableFetchAll<ProductWaffle>(ProductWaffle.SQLSelectCommand);
        }
        public static List<ProductAddition> GetAllProductAdditions()
        {
            return TableFetchAll<ProductAddition>(ProductAddition.SQLSelectCommand);
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
