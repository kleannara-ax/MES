using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SAMMI
{
    public abstract class GridBase
    {
        public struct RowHeaderFlag
        {
            public static string MARK_INSERT;
            public static string MARK_UPDATE;
            public static string MARK_DELETE;
            public static string MARK_NULL;
            //static RowHeaderFlag();
        }

        public enum InsertRowPosition
        {
            First,
            Forward,
            Next,
            Last
        }
    }
}
