using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Collections;

namespace SmartDas.Components
{
    #region 버튼 데이터
    public class ButtonData
    {
        public string Name;
        public Font Font;
        public string Text;
        public object Tag;

        private bool _UseFlag;
        private bool _ButtonPressed;

        public MESButton MappingButton;
        public MESButton MappingButton_Top;
        public string ExTag;

        public ButtonBox ParentBox;

        public bool bAlarm = false;

        public Color _thisColor;

        private Hashtable _hash;

        public ButtonData()
        {
            _hash = new Hashtable();
        }

        public void SetData(MESButton btn)
        {
            this.Name = btn.Name;
            this.Font = btn.Font;
            this.Text = btn.Text;
            this.Tag = btn.Tag;
            this._UseFlag = btn.UseFlag;
            this._ButtonPressed = btn.ButtonPressed;
            this.MappingButton = btn;
            this.ExTag = btn.ExTag;
            this._thisColor = btn.BackColor;
        }        

        public bool UseFlag
        {
            get
            {
                return _UseFlag;
            }
            set
            {
                _UseFlag = value;

                if (MappingButton != null)
                {
                    MappingButton.btnData = null;
                    MappingButton.ButtonPressed = value;
                    MappingButton.btnData = this;
                }
            }
        }

        public bool ButtonPressed
        {
            get
            {
                return _ButtonPressed;
            }
            set
            {
                _ButtonPressed = value;

                if (MappingButton != null)
                {
                    MappingButton.btnData = null;
                    MappingButton.ButtonPressed = value;
                    MappingButton.btnData = this;
                }
            }
        }

        public void SetValue(string name, object obj)
        {
            if (_hash[name] == null)
            {
                _hash.Add(name, obj);
            }
            else
            {
                _hash[name] = obj;
            }
        }

        public object this[string name]
        {
            get { return _hash[name]; }
            set { _hash[name] = value; }
        }
    }
    #endregion
}
