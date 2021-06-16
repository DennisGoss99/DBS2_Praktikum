using System;
using System.Collections.Generic;
using System.Text;
using WaffleDB;

namespace WaffleDBAPI
{
    public static class WaffleConstruction
    {

        //public List<KeyValuePair<Ingredient, int>> _IngredientList = new List<KeyValuePair<Ingredient, int>>();

        //public WaffleConstruction()
        //{

        //}

        //public void AddIngredient(Ingredient ingredient, int amount)
        //{
            
        //}

        public static bool CreateWaffle(List<KeyValuePair<Ingredient, int>> _IngredientList)
        {
            if(_IngredientList.Count == 0)
                return false;

            return true;
        }
        
    }
}
