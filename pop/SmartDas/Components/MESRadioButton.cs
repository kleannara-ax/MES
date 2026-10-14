using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Windows.Forms;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace SmartDas.Components
{
    class MESRadioButton : RadioButton
    {
        // Fields
        private Color checkedColor = Color.Black;
        private Color unCheckedColor = Color.Gray;

        private float mesBorderSize = 18F;
        private float mesCheckSize = 12F;

        //Proerties
        public Color CheckedColor
        {
            get
            {
                return checkedColor;
            }
            set
            {
                checkedColor = value;
                this.Invalidate();
            }
        }

        public Color UnCheckedColor
        {
            get
            {
                return unCheckedColor;
            }
            set
            {
                unCheckedColor = value;
                this.Invalidate();
            }
        }

        public float MesBoardSize
        {
            get
            {
                return mesBorderSize;
            }
            set
            {
                mesBorderSize = value;
                this.Invalidate();
            }
        }

        public float MesCheckSize
        {
            get
            {
                return mesCheckSize;
            }
            set
            {
                mesCheckSize = value;
                this.Invalidate();
            }
        }


        // Constructor
        public MESRadioButton()
        {
            this.MinimumSize = new Size(0, 21);

        }

        // Overridden methods
        protected override void OnPaint(PaintEventArgs pevent)
        {
            // Fields
            Graphics graphics = pevent.Graphics;
            graphics.SmoothingMode = SmoothingMode.AntiAlias;


            RectangleF rectRbBoard = new RectangleF()
            {
                X = 0.5F,
                Y = (this.Height - mesBorderSize) / 2, //Center
                Width = mesBorderSize,
                Height = mesBorderSize
            };

            RectangleF rectRbCheck = new RectangleF()
            {
                X = rectRbBoard.X + ((rectRbBoard.Width - mesCheckSize) / 2),
                Y = (this.Height - mesCheckSize) / 2,
                Width = mesCheckSize,
                Height = mesCheckSize
            };

            // Drawing
            using (Pen penBoard = new Pen(checkedColor, 1.6F))
            using (SolidBrush brushRbCheck = new SolidBrush(checkedColor))
            using (SolidBrush brushText = new SolidBrush(this.ForeColor))
            {
                // Draw surface
                // bug fix : this.BackColor가 "Transparent" 인경우 검정색으로 지정되어 Parent.BackColor로 지정하도록 수정
                if (this.BackColor.Name.Equals("Transparent"))      
                {
                    graphics.Clear(Parent.BackColor);
                }
                else
                {
                    graphics.Clear(this.BackColor);
                }

                // Draw Radio Button
                if (this.Checked)
                {
                    graphics.DrawEllipse(penBoard, rectRbBoard);        // Circle border
                    graphics.FillEllipse(brushRbCheck, rectRbCheck);    // Circle Radio Chedck
                }
                else
                {
                    penBoard.Color = unCheckedColor;

                    graphics.DrawEllipse(penBoard, rectRbBoard);        // Circle border
                }

                // Draw Text
                graphics.DrawString(this.Text, this.Font, brushText,
                    mesBorderSize + 8, (this.Height - TextRenderer.MeasureText(this.Text, this.Font).Height) / 2);       // Y=Center
            }
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);
            this.Width = TextRenderer.MeasureText(this.Text, this.Font).Width + 30;

        }

    }
}
