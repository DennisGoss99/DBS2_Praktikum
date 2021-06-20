using System;

namespace WaffleDB
{
    public class IngredientInventory : IIngredient, IInventory
    {
        /** 
         * Ingredients
         */
        public int idIngredient { get; set; }
        public int idNuIn { get; set; }
        public string name { get; set; }
        public string unit { get; set; }
        private float _price { get; set; }
        public float price
        {
            get { return _price * 1.19f; }

            set { _price = value; }

        }
        public int processingTimeSec { get; set; }
        public int canPutOnWaffle { get; set; }

        /**
         * Inventory
         */
        public int idInventory { get; set; }
        public int idStore { get; set; }
        public DateTime expiryDate { get; set; }
        public DateTime deliveryDate { get; set; }
        public int amount { get; set; }
        public int isAccessible { get; set; }

        public static string SQLSelectCommand
        {
            get =>
                "select * from Ingredient" +
                " inner join Inventory on Ingredient.idIngredient = Inventory.idIngredient";
        }

    }
}
