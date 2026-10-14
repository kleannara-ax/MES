using SmartDas.Components;

namespace SmartDas
{
    partial class POP_INV04
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_INV04));
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.txtIND_BCD = new System.Windows.Forms.TextBox();
            this.txtVLEN = new System.Windows.Forms.TextBox();
            this.txtWLEN = new System.Windows.Forms.TextBox();
            this.txtWEIGHT = new System.Windows.Forms.TextBox();
            this.txtPCODE = new System.Windows.Forms.TextBox();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.mesLabel2 = new SmartDas.Components.MESLabel();
            this.mesLabel1 = new SmartDas.Components.MESLabel();
            this.lblText = new SmartDas.Components.MESLabel();
            this.bGroup = new SmartDas.Components.ButtonBox();
            this.label1 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.txtIND_BCD);
            this.splitContainer1.Panel1.Controls.Add(this.txtVLEN);
            this.splitContainer1.Panel1.Controls.Add(this.txtWLEN);
            this.splitContainer1.Panel1.Controls.Add(this.txtWEIGHT);
            this.splitContainer1.Panel1.Controls.Add(this.txtPCODE);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.mesLabel2);
            this.splitContainer1.Panel1.Controls.Add(this.mesLabel1);
            this.splitContainer1.Panel1.Controls.Add(this.lblText);
            this.splitContainer1.Panel1.Controls.Add(this.bGroup);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 0;
            // 
            // txtIND_BCD
            // 
            this.txtIND_BCD.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtIND_BCD.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtIND_BCD.Location = new System.Drawing.Point(956, 7);
            this.txtIND_BCD.MaxLength = 15;
            this.txtIND_BCD.MinimumSize = new System.Drawing.Size(180, 40);
            this.txtIND_BCD.Name = "txtIND_BCD";
            this.txtIND_BCD.Size = new System.Drawing.Size(200, 40);
            this.txtIND_BCD.TabIndex = 234;
            this.txtIND_BCD.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtIND_BCD.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtPCODE_KeyPress);
            // 
            // txtVLEN
            // 
            this.txtVLEN.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtVLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtVLEN.Location = new System.Drawing.Point(777, 7);
            this.txtVLEN.MaxLength = 4;
            this.txtVLEN.MinimumSize = new System.Drawing.Size(70, 40);
            this.txtVLEN.Name = "txtVLEN";
            this.txtVLEN.Size = new System.Drawing.Size(70, 40);
            this.txtVLEN.TabIndex = 233;
            this.txtVLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtVLEN.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtContent_KeyPress);
            // 
            // txtWLEN
            // 
            this.txtWLEN.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWLEN.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtWLEN.Location = new System.Drawing.Point(628, 7);
            this.txtWLEN.MaxLength = 4;
            this.txtWLEN.MinimumSize = new System.Drawing.Size(70, 40);
            this.txtWLEN.Name = "txtWLEN";
            this.txtWLEN.Size = new System.Drawing.Size(70, 40);
            this.txtWLEN.TabIndex = 232;
            this.txtWLEN.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtWLEN.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtContent_KeyPress);
            // 
            // txtWEIGHT
            // 
            this.txtWEIGHT.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWEIGHT.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtWEIGHT.Location = new System.Drawing.Point(488, 7);
            this.txtWEIGHT.MaxLength = 4;
            this.txtWEIGHT.MinimumSize = new System.Drawing.Size(70, 40);
            this.txtWEIGHT.Name = "txtWEIGHT";
            this.txtWEIGHT.Size = new System.Drawing.Size(70, 40);
            this.txtWEIGHT.TabIndex = 211;
            this.txtWEIGHT.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtWEIGHT.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtContent_KeyPress);
            // 
            // txtPCODE
            // 
            this.txtPCODE.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtPCODE.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPCODE.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtPCODE.Location = new System.Drawing.Point(341, 7);
            this.txtPCODE.MaxLength = 3;
            this.txtPCODE.MinimumSize = new System.Drawing.Size(70, 40);
            this.txtPCODE.Name = "txtPCODE";
            this.txtPCODE.Size = new System.Drawing.Size(70, 40);
            this.txtPCODE.TabIndex = 210;
            this.txtPCODE.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtPCODE.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtPCODE_KeyPress);
            // 
            // btnFind
            // 
            this.btnFind.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnFind.BackColor = System.Drawing.Color.Transparent;
            this.btnFind.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnFind.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnFind.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnFind.ButtonPressed = false;
            this.btnFind.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnFind.DownPic = null;
            this.btnFind.ExTag = null;
            this.btnFind.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(1168, 7);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(100, 40);
            this.btnFind.TabIndex = 209;
            this.btnFind.Text = "조회";
            this.btnFind.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnFind.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnFind.UpPic = null;
            this.btnFind.UseFlag = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // Grid1
            // 
            this.Grid1.AutoScroll = true;
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.CellSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(8, 133);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1260, 650);
            this.Grid1.TabIndex = 185;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.GridDoubleClick += new SmartDas.Components.MESGrid.gridDoubleClick(this.Grid1_GridDoubleClick);
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(854, 7);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(100, 40);
            this.label7.TabIndex = 183;
            this.label7.Text = "개별바코드";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(715, 7);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(60, 40);
            this.label6.TabIndex = 181;
            this.label6.Text = "세로";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(566, 7);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(60, 40);
            this.label3.TabIndex = 179;
            this.label3.Text = "가로";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(426, 7);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(60, 40);
            this.label2.TabIndex = 177;
            this.label2.Text = "평량";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // mesLabel2
            // 
            this.mesLabel2.BackColor = System.Drawing.Color.White;
            this.mesLabel2.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.mesLabel2.ColorContent = System.Drawing.Color.Transparent;
            this.mesLabel2.ColorLabel = System.Drawing.Color.White;
            this.mesLabel2.ColorReadOnly = System.Drawing.Color.Transparent;
            this.mesLabel2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesLabel2.LabelPadding = new System.Drawing.Size(0, 0);
            this.mesLabel2.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.mesLabel2.Location = new System.Drawing.Point(122, 7);
            this.mesLabel2.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.mesLabel2.MoveControl = null;
            this.mesLabel2.Name = "mesLabel2";
            this.mesLabel2.Size = new System.Drawing.Size(120, 40);
            this.mesLabel2.TabIndex = 176;
            this.mesLabel2.Text = "밀롤창고출고";
            this.mesLabel2.TextHAlign = Infragistics.Win.HAlign.Center;
            this.mesLabel2.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // mesLabel1
            // 
            this.mesLabel1.BackColor = System.Drawing.Color.White;
            this.mesLabel1.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.mesLabel1.ColorContent = System.Drawing.Color.Transparent;
            this.mesLabel1.ColorLabel = System.Drawing.Color.White;
            this.mesLabel1.ColorReadOnly = System.Drawing.Color.Transparent;
            this.mesLabel1.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesLabel1.ForeColor = System.Drawing.Color.Blue;
            this.mesLabel1.LabelPadding = new System.Drawing.Size(0, 0);
            this.mesLabel1.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.mesLabel1.Location = new System.Drawing.Point(64, 7);
            this.mesLabel1.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.mesLabel1.MoveControl = null;
            this.mesLabel1.Name = "mesLabel1";
            this.mesLabel1.Size = new System.Drawing.Size(60, 40);
            this.mesLabel1.TabIndex = 175;
            this.mesLabel1.Text = "3호기";
            this.mesLabel1.TextHAlign = Infragistics.Win.HAlign.Center;
            this.mesLabel1.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblText
            // 
            this.lblText.BackColor = System.Drawing.Color.White;
            this.lblText.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblText.ColorContent = System.Drawing.Color.Transparent;
            this.lblText.ColorLabel = System.Drawing.Color.White;
            this.lblText.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblText.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblText.ForeColor = System.Drawing.Color.Red;
            this.lblText.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblText.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblText.Location = new System.Drawing.Point(6, 7);
            this.lblText.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblText.MoveControl = null;
            this.lblText.Name = "lblText";
            this.lblText.Size = new System.Drawing.Size(60, 40);
            this.lblText.TabIndex = 162;
            this.lblText.Text = "2호기";
            this.lblText.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblText.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bGroup
            // 
            this.bGroup.BackColor = System.Drawing.Color.Transparent;
            this.bGroup.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bGroup.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bGroup.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bGroup.CountX = 1;
            this.bGroup.CountY = 1;
            this.bGroup.CurrentPage = 0;
            this.bGroup.ExTag = "";
            this.bGroup.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bGroup.FontSize = 24F;
            this.bGroup.Location = new System.Drawing.Point(7, 59);
            this.bGroup.MarginIn = new System.Windows.Forms.Padding(3);
            this.bGroup.MarginOut = new System.Windows.Forms.Padding(3);
            this.bGroup.Name = "bGroup";
            this.bGroup.SelectCommand = null;
            this.bGroup.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bGroup.SelectProcedureName = null;
            this.bGroup.Size = new System.Drawing.Size(1260, 70);
            this.bGroup.TabIndex = 161;
            this.bGroup.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bGroup_buttonChangeEvent);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(250, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(90, 40);
            this.label1.TabIndex = 121;
            this.label1.Text = "지종코드";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 65;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // POP_INV04
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_INV04";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_INV04_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private System.Windows.Forms.Label label1;
        private ButtonBox bGroup;
        private MESLabel lblText;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private MESLabel mesLabel2;
        private MESLabel mesLabel1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private System.Windows.Forms.TextBox txtIND_BCD;
        private System.Windows.Forms.TextBox txtVLEN;
        private System.Windows.Forms.TextBox txtWLEN;
        private System.Windows.Forms.TextBox txtWEIGHT;
        private System.Windows.Forms.TextBox txtPCODE;



    }
}
