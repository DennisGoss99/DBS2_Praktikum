using System;

namespace WaffleDB
{
    public interface IInventory
    {
        int amount { get; set; }
        DateTime deliveryDate { get; set; }
        DateTime expiryDate { get; set; }
        int idIngredient { get; set; }
        int idInventory { get; set; }
        int idStore { get; set; }
        int isAccessible { get; set; }
    }
}