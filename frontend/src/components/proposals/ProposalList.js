import React, {useState, useRef} from 'react';
import { useNavigate } from "react-router-dom";
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { Button, CardActionArea, CardActions } from '@mui/material';

const ProposalList = ({toDoList}) => {

    const navigate = useNavigate();

    const routeChange = (id) =>{ 
      let path = `proposal/` + id ; 
      navigate(path);
    }

   return (
       <div>
           {toDoList.map(todo => {
               return (
                <Card sx={{ maxWidth: 800 }}>
                <CardActionArea>
                  {/* <CardMedia
                    component="img"
                    height="140"
                    image="/home/muskan/buildIt/my-app/public/logo192.png"
                    alt="green iguana"
                  /> */}
                  <CardContent>
                    <Typography gutterBottom variant="h5" component="div">
                      Proposal {todo.id}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {todo.task}
                    </Typography>
                  </CardContent>
                </CardActionArea>
                <CardActions>
                  <Button size="small" color="primary" onClick={() => routeChange(todo.id)}>
                    Open
                  </Button>
                </CardActions>
              </Card>
               )
           })}
        
       </div>
   );
};
 
export default ProposalList