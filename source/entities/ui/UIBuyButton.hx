package entities.ui;

class UIBuyButton extends UIButton
{
    public function new(x:Float, y:Float, clickFunc:() -> Void)
    {
        super(x, y, "graphics/UIAddButton.png", 11, 11, clickFunc);
    }
}