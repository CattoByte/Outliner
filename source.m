disp("Booting up...") %Sample command to remove function error.
function outliner
  disp("_______/\\\\\\\\\\___________________________________/\\\\\\\\\\\\_____________________________________________________");
  disp(" _____/\\\\\\///\\\\\\________________________________\\////\\\\\\_____________________________________________________");
  disp("  ___/\\\\\\/__\\///\\\\\\____________________/\\\\\\_________\\/\\\\\\_____/\\\\\\____________________________________________");
  disp("   __/\\\\\\______\\//\\\\\\__/\\\\\\____/\\\\\\__/\\\\\\\\\\\\\\\\\\\\\\____\\/\\\\\\____\\///___/\\\\/\\\\\\\\\\\\_______/\\\\\\\\\\\\\\\\___/\\\\/\\\\\\\\\\\\\\__");
  disp("    _\\/\\\\\\_______\\/\\\\\\_\\/\\\\\\___\\/\\\\\\_\\////\\\\\\////_____\\/\\\\\\_____/\\\\\\_\\/\\\\\\////\\\\\\____/\\\\\\/////\\\\\\_\\/\\\\\\/////\\\\\\_");
  disp("     _\\//\\\\\\______/\\\\\\__\\/\\\\\\___\\/\\\\\\____\\/\\\\\\_________\\/\\\\\\____\\/\\\\\\_\\/\\\\\\__\\//\\\\\\__/\\\\\\\\\\\\\\\\\\\\\\__\\/\\\\\\___\\///__");
  disp("      __\\///\\\\\\__/\\\\\\____\\/\\\\\\___\\/\\\\\\____\\/\\\\\\_/\\\\_____\\/\\\\\\____\\/\\\\\\_\\/\\\\\\___\\/\\\\\\_\\//\\\\///////___\\/\\\\\\_________");
  disp("       ____\\///\\\\\\\\\\/_____\\//\\\\\\\\\\\\\\\\\\_____\\//\\\\\\\\\\____/\\\\\\\\\\\\\\\\\\_\\/\\\\\\_\\/\\\\\\___\\/\\\\\\__\\//\\\\\\\\\\\\\\\\\\\\_\\/\\\\\\_________");
  disp("        ______\\/////________\\/////////_______\\/////____\\/////////__\\///__\\///____\\///____\\//////////__\\///__________");
endfunction
outliner();
disp("By CattoByte! 1.0v")
disp("Loading packages...")
pkg load image;
pkg load miscellaneous;

disp("Setting functions...")

function singleimg(imgpath,val,pxcm)           %Allow function to include arguments in the form of variables

%disp("Input Image Path:")
%img = input("","s");                 %"s" Makes the string be read literally
%disp("Reading Image...");
%img = imread(img);
%
%disp("Input Threshold for BW transformation (0 to 10)");
%val = input("")/10;

%Code up there was moved to when this option has been selected,
%so when it comes to multiple image area reading you can loop this without it asking any more details

disp("Reading Image...");
img = imread(imgpath);

disp("Transforming Image into Black and White Binary Image...");
bwimg = im2bw(img,val);

disp("Applying Filters to help Processing...");
figure();
imshow(bwimg);
refresh();

disp("Using spur algorithm...");
bwimg = bwmorph(bwimg,"spur",Inf);
imshow(bwimg);
refresh();

disp("Eroding...");
bwimg = bwmorph(bwimg,"erode");
imshow(bwimg);
refresh();

disp("Spuring again...");
bwimg = bwmorph(bwimg,"spur",Inf);
imshow(bwimg);
refresh();

disp("Using majority algorithm...");
bwimg = bwmorph(bwimg,"majority",Inf);
imshow(bwimg);
refresh();

disp("Removing Noise...");
bwimg = wiener2(bwimg);
imshow(bwimg);
refresh();

disp("Closing...");
bwimg = bwmorph(bwimg,"close",Inf);
imshow(bwimg);
refresh();

disp("Eroding again to restore image precission...");
bwimg = bwmorph(bwimg,"erode");
imshow(bwimg);
refresh();

disp("Inverting Image for Area calculation...");
bwimg = not(bwimg);
imshow(bwimg);
refresh();

disp("Filtering finished!");

disp("Calculating Boundaries...");
bounds = bwboundaries(bwimg,8,"noholes");

disp("Rendering Boundaries...");
hold on                              %Retain plot data and settings instead of replacing
for i=1:numel(bounds)                %Count objects referenced in bounds variable
  plot(bounds{i}(:, 2),bounds{i}(:, 1),'r','linewidth',2);
  text_waitbar(i/numel(bounds), "Processing...");
  refresh();
  beep();
endfor
hold off

disp("Calculating Area...");
area = bwarea(bwimg);

%pxarea  = pxcm
%objarea = ?

format long;                         %I need them decimal places
info = imfinfo(imgpath);
pxcm = area*pxcm/(info.Height*info.Width)   ;

disp(["Image Area: ",num2str(area), " pixels, ",num2str(pxcm), " centimeters"]);


endfunction

disp("Setting Variables...")
opt = cell(2,1);                      %Make option variable have N cells, 'cause it's an array

disp("Please input selection:");
disp("1. Single-Image");
disp("2. Boxxer Method")
disp("3. Options (Broken)");
sel = input("Input: ");

if (sel == 1)
  clc();
  outliner();
  disp("Input Image Path:")
  imgpath = input("","s");                 %"s" Makes the string be read literally

  disp("Input Threshold for BW transformation (0 to 10)");
  val = input("")/10;
  
  info = imfinfo(imgpath);
  disp(["Input Image's Area in cm (", num2str(info.Width),"X",num2str(info.Height),"px)"]);
  pxcm = input("");
  
  singleimg(imgpath,val,pxcm);             %Load needed variables into the corresponding function variables
elseif (sel == 2)
  disp("Input Image Path:")
  imgpath = input("","s");                 %"s" Makes the string be read literally

  disp("Input Threshold for BW transformation (0 to 10)");
  val = input("")/10;
  img = imread(imgpath);
  bw = im2bw(img,val);
  bw = not(bw);
  
  stats = [regionprops(bw); regionprops(not(bw))]; % Find both black and white regions (think it's here)
  imshow(bw);

  hold on;                                 %Retain plot data and settings instead of replacing (again)
  for i = 1:numel(stats)
    rectangle('Position', stats(i).BoundingBox, 'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
    
  endfor
  
  for i = 1:numel(stats);                  %Value 1 is X, 2 is Y, 3 is X2, and 4 is Y2
    
    x = stats(i).BoundingBox(1);
    y = stats(i).BoundingBox(2);
    x2 = stats(i).BoundingBox(3);
    y2 = stats(i).BoundingBox(4);
    threshold = 100;
    y2new = (y2-threshold):(y2+threshold); %Don't make it a vector, [], so it doesn't store the numbers, instead use a range that only stores x:y
    equation = y+(x2-x);                   %Equation I made to see if a rectangle is a square, Y+(X2-X)=Y2, if passed the rectangle is a square
    
    if (any(equation == y2new) == 1)
      reference = stats(i);                   
      rectangle('Position', reference.BoundingBox, 'Linewidth', 4, 'Edgecolor', 'b');
    endif
  endfor
  x = reference.BoundingBox(1);
  y = reference.BoundingBox(2);
  x2 = reference.BoundingBox(3);
  y2 = reference.BoundingBox(4);
  boxarea = (x2-x) * (y2-y);
  disp(["Box area: ", num2str(boxarea),"px = 1m"]);
  objectarea = bwarea(bw);
  totalarea = objectarea/boxarea;          %Rule of three, objectarea*1cm/boxarea
  disp(["Object area: ",num2str(totalarea),"cm"])
  
elseif (sel == 3)
  clc();
  outliner();
  disp("Options:");
  disp("Calculate area in cm? ");
  disp("Please input Selection:");
  sel = input("","s");                 %Using "s" just in case lmao
  if (sel == something)
    %codehereplease
  endif
endif
disp("Finished! Cya next time~");      %Took advantage of this space to put this,
                                       %So the if command line doesn't go out and obliterate my comfort
                                       %I mean the indicator that connects ifs like parent and child.
%Old code I don't need.

%for i=0:11 %Chose 11 so it goes from 0 to 1 when divided by 10
%  traced = edge(grscale,"Canny",i/10);
%  figure();
%  imshow(traced);
%endfor


%To do list:
% Fix waitbar on singleimg
% Include actual leaf measurer with "boxer" method.
% Include IMG GUI
% Remove Pain
% Polish depain
% Completely Obliterate pain
% (Pain is the usage of the program)
% Test total GUI
% If possible, use tkinter from python and mutil-no, disme-uh, reduce the total pain to minimal integers/floating points.
% Implement auto mode compatible with GUI mode.