function disable_frame( frame )

   set( frame, 'ForegroundColor', constant_define( 'COLOR_INACTIVE' ) );
   
   child = get( frame, 'Children' );
   if size(child,1) > 0
       
     for thisChild = 1:size(child,1)
   
       switch get( child(thisChild), 'Style' )
     
         case { 'pushbutton' 'togglebutton' 'radiobutton' 'listbox' 'popupmenu' }
             set( child(thisChild), 'Enable', 'off' );
           
         case 'edit'
             set( child(thisChild), 'Enable', 'off' );
             set( child(thisChild), 'String', '' );
           
         case 'text'
             set( child(thisChild), 'Enable', 'off' );

       end;
     
     end

  end
 
